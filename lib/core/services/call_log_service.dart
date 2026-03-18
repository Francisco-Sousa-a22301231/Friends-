import 'package:call_log/call_log.dart' as native_call_log;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/contact_communication.dart';

/// F1.1 / US1.1.1: Reads the device's native call log.
/// On web, returns demo data for testing.
class CallLogService {
  /// Fetches all call log entries and maps them to [CommunicationRecord].
  Future<List<CommunicationRecord>> fetchCallHistory() async {
    if (kIsWeb) {
      return _generateDemoCallData();
    }
    return await _fetchNativeCallLog();
  }

  Future<List<CommunicationRecord>> _fetchNativeCallLog() async {
    final Iterable<native_call_log.CallLogEntry> entries =
        await native_call_log.CallLog.get();

    return entries.map((entry) {
      return CommunicationRecord(
        id: 'call_${entry.timestamp ?? DateTime.now().millisecondsSinceEpoch}',
        contactName: (entry.name != null && entry.name!.isNotEmpty)
            ? entry.name!
            : 'Unknown',
        phoneNumber: entry.number ?? '',
        type: CommunicationType.call,
        timestamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
        durationSeconds: entry.duration,
      );
    }).where((record) => record.phoneNumber.isNotEmpty).toList();
  }

  /// Fetches call history filtered by a specific phone number.
  Future<List<CommunicationRecord>> fetchCallsForNumber(
      String phoneNumber) async {
    final all = await fetchCallHistory();
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
  List<CommunicationRecord> _generateDemoCallData() {
    final now = DateTime.now();
    return [
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
        contactName: 'João Silva',
        phoneNumber: '+351961234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 3)),
        durationSeconds: 120,
      ),
      CommunicationRecord(
        id: 'call_3',
        contactName: 'Maria Santos',
        phoneNumber: '+351931234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 15)),
        durationSeconds: 60,
      ),
      CommunicationRecord(
        id: 'call_4',
        contactName: 'Pai',
        phoneNumber: '+351921234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 45)),
        durationSeconds: 180,
      ),
      CommunicationRecord(
        id: 'call_5',
        contactName: 'Ana Costa',
        phoneNumber: '+351941234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 90)),
        durationSeconds: 45,
      ),
      CommunicationRecord(
        id: 'call_6',
        contactName: 'Pedro Oliveira',
        phoneNumber: '+351951234567',
        type: CommunicationType.call,
        timestamp: now.subtract(const Duration(days: 200)),
        durationSeconds: 600,
      ),
    ];
  }
}
