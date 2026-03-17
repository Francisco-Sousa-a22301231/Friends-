import 'package:call_log/call_log.dart';

import '../models/contact_communication.dart';

/// F1.1 / US1.1.1: Reads the device's native call log.
class CallLogService {
  /// Fetches all call log entries and maps them to [CommunicationRecord].
  Future<List<CommunicationRecord>> fetchCallHistory() async {
    final Iterable<CallLogEntry> entries = await CallLog.get();

    return entries.map((entry) {
      return CommunicationRecord(
        id: 'call_${entry.timestamp}',
        contactName: entry.name ?? 'Unknown',
        phoneNumber: entry.number ?? '',
        type: CommunicationType.call,
        timestamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
        durationSeconds: entry.duration,
      );
    }).toList();
  }

  /// Fetches call history filtered by a specific phone number.
  Future<List<CommunicationRecord>> fetchCallsForNumber(
      String phoneNumber) async {
    final all = await fetchCallHistory();
    return all
        .where((record) => _normalizePhone(record.phoneNumber) ==
            _normalizePhone(phoneNumber))
        .toList();
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
