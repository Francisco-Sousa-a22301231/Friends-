import 'package:flutter_test/flutter_test.dart';
import 'package:friends_app/core/models/contact_communication.dart';

void main() {
  group('CommunicationRecord', () {
    test('toMap and fromMap round-trip correctly', () {
      final record = CommunicationRecord(
        id: 'call_123',
        contactName: 'João',
        phoneNumber: '+351912345678',
        type: CommunicationType.call,
        timestamp: DateTime(2025, 6, 15, 14, 30),
        durationSeconds: 120,
      );

      final map = record.toMap();
      final restored = CommunicationRecord.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.contactName, record.contactName);
      expect(restored.phoneNumber, record.phoneNumber);
      expect(restored.type, record.type);
      expect(restored.timestamp, record.timestamp);
      expect(restored.durationSeconds, record.durationSeconds);
    });

    test('SMS record has null durationSeconds', () {
      final record = CommunicationRecord(
        id: 'sms_456',
        contactName: 'Maria',
        phoneNumber: '+351961234567',
        type: CommunicationType.sms,
        timestamp: DateTime(2025, 6, 10),
      );

      expect(record.durationSeconds, isNull);
      expect(record.type, CommunicationType.sms);
    });
  });

  group('ContactSummary', () {
    test('correctly represents aggregated contact data', () {
      final now = DateTime.now();
      final lastContact = now.subtract(const Duration(days: 15));

      final summary = ContactSummary(
        contactName: 'Pedro',
        phoneNumber: '+351931234567',
        lastCommunication: lastContact,
        lastType: CommunicationType.call,
        timeSinceLastContact: now.difference(lastContact),
        totalCalls: 5,
        totalMessages: 12,
      );

      expect(summary.timeSinceLastContact.inDays, 15);
      expect(summary.totalCalls, 5);
      expect(summary.totalMessages, 12);
    });
  });
}
