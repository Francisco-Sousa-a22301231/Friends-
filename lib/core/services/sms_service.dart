import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as native_sms;

import '../models/contact_communication.dart';

/// F1.1 / US1.1.2: Reads the device's native SMS inbox.
/// On web, returns demo data for testing.
class SmsService {
  /// Fetches all SMS messages and maps them to [CommunicationRecord].
  Future<List<CommunicationRecord>> fetchSmsHistory() async {
    if (kIsWeb) {
      return _generateDemoSmsData();
    }
    return await _fetchNativeSms();
  }

  Future<List<CommunicationRecord>> _fetchNativeSms() async {
    final query = native_sms.SmsQuery();
    final List<native_sms.SmsMessage> messages = await query.getAllSms;

    return messages.map((message) {
      final address = message.address ?? '';
      return CommunicationRecord(
        id: 'sms_${message.id ?? DateTime.now().millisecondsSinceEpoch}',
        contactName: (message.sender != null && message.sender!.isNotEmpty)
            ? message.sender!
            : 'Unknown',
        phoneNumber: address,
        type: CommunicationType.sms,
        timestamp: message.date ?? DateTime.now(),
      );
    }).where((record) => record.phoneNumber.isNotEmpty).toList();
  }

  /// Fetches SMS history filtered by a specific phone number.
  Future<List<CommunicationRecord>> fetchSmsForNumber(
      String phoneNumber) async {
    final all = await fetchSmsHistory();
    return all
        .where((record) =>
            _normalizePhone(record.phoneNumber) ==
            _normalizePhone(phoneNumber))
        .toList();
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Demo data for web testing.
  List<CommunicationRecord> _generateDemoSmsData() {
    final now = DateTime.now();
    return [
      CommunicationRecord(
        id: 'sms_1',
        contactName: 'Mãe',
        phoneNumber: '+351912345678',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      CommunicationRecord(
        id: 'sms_2',
        contactName: 'João Silva',
        phoneNumber: '+351961234567',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      CommunicationRecord(
        id: 'sms_3',
        contactName: 'Avó Teresa',
        phoneNumber: '+351911234567',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(days: 60)),
      ),
      CommunicationRecord(
        id: 'sms_4',
        contactName: 'Pai',
        phoneNumber: '+351921234567',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(days: 10)),
      ),
      CommunicationRecord(
        id: 'sms_5',
        contactName: 'Tio Manuel',
        phoneNumber: '+351971234567',
        type: CommunicationType.sms,
        timestamp: now.subtract(const Duration(days: 365)),
      ),
    ];
  }
}
