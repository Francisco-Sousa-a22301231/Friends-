import '../models/contact_communication.dart';
import 'call_log_service.dart';
import 'database_service.dart';
import 'sms_service.dart';

/// F1.4 / US1.1.3: Combines call and SMS data per contact to produce
/// a unified "last contact" calculation. Persists records to the local
/// database for offline access and caching.
class ContactAggregatorService {
  final CallLogService _callLogService;
  final SmsService _smsService;
  final DatabaseService _databaseService;

  ContactAggregatorService({
    CallLogService? callLogService,
    SmsService? smsService,
    DatabaseService? databaseService,
  })  : _callLogService = callLogService ?? CallLogService(),
        _smsService = smsService ?? SmsService(),
        _databaseService = databaseService ?? DatabaseService.instance;

  /// Fetches fresh data from native sources, persists to DB, and returns
  /// aggregated [ContactSummary] list sorted by longest time since contact.
  Future<List<ContactSummary>> getContactSummaries() async {
    final calls = await _callLogService.fetchCallHistory();
    final messages = await _smsService.fetchSmsHistory();

    final allRecords = [...calls, ...messages];

    // Persist fetched records to local database
    if (allRecords.isNotEmpty) {
      await _databaseService.upsertRecords(allRecords);
    }

    return _buildSummaries(allRecords);
  }

  /// Returns summaries from locally cached DB records only (no native fetch).
  Future<List<ContactSummary>> getCachedSummaries() async {
    final records = await _databaseService.getAllRecords();
    return _buildSummaries(records);
  }

  /// Groups records by phone number and builds [ContactSummary] list.
  List<ContactSummary> _buildSummaries(List<CommunicationRecord> allRecords) {
    // Group by normalized phone number
    final Map<String, List<CommunicationRecord>> grouped = {};
    for (final record in allRecords) {
      final key = _normalizePhone(record.phoneNumber);
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final now = DateTime.now();
    final summaries = <ContactSummary>[];

    for (final entry in grouped.entries) {
      final records = entry.value;
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final latest = records.first;
      final callCount =
          records.where((r) => r.type == CommunicationType.call).length;
      final smsCount =
          records.where((r) => r.type == CommunicationType.sms).length;

      // Use the best available contact name (prefer non-"Unknown")
      final bestName = records
              .map((r) => r.contactName)
              .firstWhere((name) => name != 'Unknown',
                  orElse: () => 'Unknown');

      summaries.add(ContactSummary(
        contactName: bestName,
        phoneNumber: entry.key,
        lastCommunication: latest.timestamp,
        lastType: latest.type,
        timeSinceLastContact: now.difference(latest.timestamp),
        totalCalls: callCount,
        totalMessages: smsCount,
      ));
    }

    // Sort by time since last contact (longest first — people you haven't
    // talked to in the longest time appear at the top)
    summaries.sort((a, b) =>
        b.timeSinceLastContact.compareTo(a.timeSinceLastContact));

    return summaries;
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
