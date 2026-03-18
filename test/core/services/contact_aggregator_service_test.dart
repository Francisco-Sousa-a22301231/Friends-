import 'package:flutter_test/flutter_test.dart';
import 'package:friends_app/core/models/contact_communication.dart';
import 'package:friends_app/core/services/contact_aggregator_service.dart';
import 'package:friends_app/core/services/call_log_service.dart';
import 'package:friends_app/core/services/sms_service.dart';
import 'package:friends_app/core/services/database_service.dart';

/// Fake CallLogService that returns controlled test data.
class FakeCallLogService extends CallLogService {
  final List<CommunicationRecord> _records;
  FakeCallLogService(this._records);

  @override
  Future<List<CommunicationRecord>> fetchCallHistory() async => _records;
}

/// Fake SmsService that returns controlled test data.
class FakeSmsService extends SmsService {
  final List<CommunicationRecord> _records;
  FakeSmsService(this._records);

  @override
  Future<List<CommunicationRecord>> fetchSmsHistory() async => _records;
}

/// Fake DatabaseService that stores records in memory (no SQLite).
class FakeDatabaseService extends DatabaseService {
  final List<CommunicationRecord> _stored = [];

  FakeDatabaseService() : super.testable();

  @override
  Future<void> upsertRecords(List<CommunicationRecord> records) async {
    for (final record in records) {
      _stored.removeWhere((r) => r.id == record.id);
      _stored.add(record);
    }
  }

  @override
  Future<List<CommunicationRecord>> getAllRecords() async {
    final sorted = List<CommunicationRecord>.from(_stored);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  List<CommunicationRecord> get storedRecords => _stored;
}

void main() {
  group('ContactAggregatorService', () {
    late FakeDatabaseService fakeDb;

    setUp(() {
      fakeDb = FakeDatabaseService();
    });

    test('combines calls and SMS for same contact', () async {
      final now = DateTime.now();
      final callRecords = [
        CommunicationRecord(
          id: 'call_1',
          contactName: 'João',
          phoneNumber: '+351912345678',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 3)),
          durationSeconds: 120,
        ),
      ];
      final smsRecords = [
        CommunicationRecord(
          id: 'sms_1',
          contactName: 'João',
          phoneNumber: '+351912345678',
          type: CommunicationType.sms,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(callRecords),
        smsService: FakeSmsService(smsRecords),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries.length, 1);
      expect(summaries.first.contactName, 'João');
      expect(summaries.first.totalCalls, 1);
      expect(summaries.first.totalMessages, 1);
      expect(summaries.first.lastType, CommunicationType.sms);
    });

    test('separates different contacts by phone number', () async {
      final now = DateTime.now();
      final callRecords = [
        CommunicationRecord(
          id: 'call_1',
          contactName: 'João',
          phoneNumber: '+351912345678',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 5)),
          durationSeconds: 60,
        ),
        CommunicationRecord(
          id: 'call_2',
          contactName: 'Maria',
          phoneNumber: '+351961234567',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 1)),
          durationSeconds: 90,
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(callRecords),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries.length, 2);
      // Sorted by longest time since contact first
      expect(summaries.first.contactName, 'João');
      expect(summaries.last.contactName, 'Maria');
    });

    test('sorts by longest time since last contact', () async {
      final now = DateTime.now();
      final records = [
        CommunicationRecord(
          id: 'call_recent',
          contactName: 'Recent',
          phoneNumber: '+351111111111',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(hours: 1)),
          durationSeconds: 30,
        ),
        CommunicationRecord(
          id: 'call_old',
          contactName: 'Old',
          phoneNumber: '+351222222222',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 100)),
          durationSeconds: 30,
        ),
        CommunicationRecord(
          id: 'call_mid',
          contactName: 'Middle',
          phoneNumber: '+351333333333',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 10)),
          durationSeconds: 30,
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(records),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries[0].contactName, 'Old');
      expect(summaries[1].contactName, 'Middle');
      expect(summaries[2].contactName, 'Recent');
    });

    test('prefers non-Unknown contact name', () async {
      final now = DateTime.now();
      final callRecords = [
        CommunicationRecord(
          id: 'call_1',
          contactName: 'Unknown',
          phoneNumber: '+351912345678',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 5)),
          durationSeconds: 60,
        ),
      ];
      final smsRecords = [
        CommunicationRecord(
          id: 'sms_1',
          contactName: 'Pedro',
          phoneNumber: '+351912345678',
          type: CommunicationType.sms,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(callRecords),
        smsService: FakeSmsService(smsRecords),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries.first.contactName, 'Pedro');
    });

    test('persists records to database', () async {
      final now = DateTime.now();
      final callRecords = [
        CommunicationRecord(
          id: 'call_1',
          contactName: 'Ana',
          phoneNumber: '+351912345678',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 2)),
          durationSeconds: 90,
        ),
      ];
      final smsRecords = [
        CommunicationRecord(
          id: 'sms_1',
          contactName: 'Ana',
          phoneNumber: '+351912345678',
          type: CommunicationType.sms,
          timestamp: now.subtract(const Duration(hours: 5)),
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(callRecords),
        smsService: FakeSmsService(smsRecords),
        databaseService: fakeDb,
      );

      await aggregator.getContactSummaries();

      expect(fakeDb.storedRecords.length, 2);
    });

    test('getCachedSummaries returns data from DB', () async {
      final now = DateTime.now();

      // Pre-populate the fake DB
      fakeDb._stored.addAll([
        CommunicationRecord(
          id: 'cached_1',
          contactName: 'Cached Contact',
          phoneNumber: '+351999999999',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 7)),
          durationSeconds: 45,
        ),
      ]);

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService([]),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getCachedSummaries();

      expect(summaries.length, 1);
      expect(summaries.first.contactName, 'Cached Contact');
    });

    test('skips records with empty phone numbers', () async {
      final now = DateTime.now();
      final records = [
        CommunicationRecord(
          id: 'call_empty',
          contactName: 'Ghost',
          phoneNumber: '',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 1)),
          durationSeconds: 10,
        ),
        CommunicationRecord(
          id: 'call_valid',
          contactName: 'Valid',
          phoneNumber: '+351111111111',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 2)),
          durationSeconds: 30,
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(records),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries.length, 1);
      expect(summaries.first.contactName, 'Valid');
    });

    test('handles empty call and SMS history', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService([]),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      expect(summaries, isEmpty);
    });

    test('normalizes phone numbers for grouping', () async {
      final now = DateTime.now();
      final callRecords = [
        CommunicationRecord(
          id: 'call_1',
          contactName: 'João',
          phoneNumber: '+351 912 345 678',
          type: CommunicationType.call,
          timestamp: now.subtract(const Duration(days: 3)),
          durationSeconds: 60,
        ),
      ];
      final smsRecords = [
        CommunicationRecord(
          id: 'sms_1',
          contactName: 'João',
          phoneNumber: '+351912345678',
          type: CommunicationType.sms,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];

      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(callRecords),
        smsService: FakeSmsService(smsRecords),
        databaseService: fakeDb,
      );

      final summaries = await aggregator.getContactSummaries();

      // Should be grouped as one contact despite different formatting
      expect(summaries.length, 1);
      expect(summaries.first.totalCalls, 1);
      expect(summaries.first.totalMessages, 1);
    });
  });
}
