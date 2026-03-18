import 'package:flutter_test/flutter_test.dart';
import 'package:friends_app/core/models/contact_communication.dart';
import 'package:friends_app/core/providers/contact_provider.dart';
import 'package:friends_app/core/services/contact_aggregator_service.dart';
import 'package:friends_app/core/services/call_log_service.dart';
import 'package:friends_app/core/services/sms_service.dart';
import 'package:friends_app/core/services/database_service.dart';

/// Fake services for testing the provider in isolation.
class FakeCallLogService extends CallLogService {
  final List<CommunicationRecord> _records;
  FakeCallLogService(this._records);

  @override
  Future<List<CommunicationRecord>> fetchCallHistory() async => _records;
}

class FakeSmsService extends SmsService {
  final List<CommunicationRecord> _records;
  FakeSmsService(this._records);

  @override
  Future<List<CommunicationRecord>> fetchSmsHistory() async => _records;
}

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
}

class FailingCallLogService extends CallLogService {
  @override
  Future<List<CommunicationRecord>> fetchCallHistory() async {
    throw Exception('Native call log unavailable');
  }
}

void main() {
  group('ContactProvider', () {
    late FakeDatabaseService fakeDb;
    final now = DateTime.now();
    final testCalls = [
      CommunicationRecord(
        id: 'call_1',
        contactName: 'Mãe',
        phoneNumber: '+351912345678',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(hours: 2)),
        durationSeconds: 340,
      ),
      CommunicationRecord(
        id: 'call_2',
        contactName: 'João',
        phoneNumber: '+351961234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 5)),
        durationSeconds: 120,
      ),
    ];
    final testSms = [
      CommunicationRecord(
        id: 'sms_1',
        contactName: 'Mãe',
        phoneNumber: '+351912345678',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    setUp(() {
      fakeDb = FakeDatabaseService();
    });

    test('loadContacts populates summaries', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(testCalls),
        smsService: FakeSmsService(testSms),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();

      expect(provider.summaries.length, 2);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.lastRefreshed, isNotNull);
    });

    test('sets error on failure', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FailingCallLogService(),
        smsService: FakeSmsService([]),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();

      expect(provider.error, isNotNull);
      expect(provider.summaries, isEmpty);
    });

    test('setFilter filters by calls only', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(testCalls),
        smsService: FakeSmsService(testSms),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();
      provider.setFilter(CommunicationType.call);

      // Both contacts have calls
      expect(provider.summaries.length, 2);
      expect(provider.filterType, CommunicationType.call);
    });

    test('setFilter filters by sms only', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(testCalls),
        smsService: FakeSmsService(testSms),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();
      provider.setFilter(CommunicationType.sms);

      // Only Mãe has SMS
      expect(provider.summaries.length, 1);
      expect(provider.summaries.first.contactName, 'Mãe');
    });

    test('setFilter null shows all contacts', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(testCalls),
        smsService: FakeSmsService(testSms),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();
      provider.setFilter(CommunicationType.sms);
      provider.setFilter(null);

      expect(provider.summaries.length, 2);
      expect(provider.filterType, isNull);
    });

    test('refresh reloads data', () async {
      final aggregator = ContactAggregatorService(
        callLogService: FakeCallLogService(testCalls),
        smsService: FakeSmsService(testSms),
        databaseService: fakeDb,
      );
      final provider = ContactProvider(aggregator: aggregator);

      await provider.loadContacts();
      final firstRefresh = provider.lastRefreshed;

      await Future.delayed(const Duration(milliseconds: 10));
      await provider.refresh();

      expect(provider.lastRefreshed, isNot(equals(firstRefresh)));
    });
  });
}
