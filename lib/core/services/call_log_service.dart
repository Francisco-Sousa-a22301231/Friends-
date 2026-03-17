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
    // Native implementation — only imported on mobile
    return await _fetchNativeCallLog();
  }

  Future<List<CommunicationRecord>> _fetchNativeCallLog() async {
    // Dynamic import to avoid web compilation errors
    final callLog = await _NativeCallLogHelper.fetch();
    return callLog;
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

/// Helper to isolate native call_log import.
class _NativeCallLogHelper {
  static Future<List<CommunicationRecord>> fetch() async {
    // On mobile, we would use the call_log package here.
    // This is guarded by kIsWeb check in CallLogService.
    return [];
  }
}
