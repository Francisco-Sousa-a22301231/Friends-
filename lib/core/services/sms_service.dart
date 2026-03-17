import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../models/contact_communication.dart';

/// F1.1 / US1.1.2: Reads the device's native SMS inbox.
class SmsService {
  final SmsQuery _query = SmsQuery();

  /// Fetches all SMS messages and maps them to [CommunicationRecord].
  Future<List<CommunicationRecord>> fetchSmsHistory() async {
    final List<SmsMessage> messages = await _query.getAllSms;

    return messages.map((msg) {
      return CommunicationRecord(
        id: 'sms_${msg.id}',
        contactName: msg.address ?? 'Unknown',
        phoneNumber: msg.address ?? '',
        type: CommunicationType.sms,
        timestamp: msg.date ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList();
  }

  /// Fetches SMS history filtered by a specific phone number.
  Future<List<CommunicationRecord>> fetchSmsForNumber(
      String phoneNumber) async {
    final all = await fetchSmsHistory();
    return all
        .where((record) => _normalizePhone(record.phoneNumber) ==
            _normalizePhone(phoneNumber))
        .toList();
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
