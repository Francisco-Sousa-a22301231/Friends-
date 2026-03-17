/// Represents a single communication event (call or SMS) with a contact.
class CommunicationRecord {
  final String id;
  final String contactName;
  final String phoneNumber;
  final CommunicationType type;
  final DateTime timestamp;
  final int? durationSeconds; // Only for calls

  const CommunicationRecord({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.type,
    required this.timestamp,
    this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
    };
  }

  factory CommunicationRecord.fromMap(Map<String, dynamic> map) {
    return CommunicationRecord(
      id: map['id'] as String,
      contactName: map['contact_name'] as String,
      phoneNumber: map['phone_number'] as String,
      type: CommunicationType.values.byName(map['type'] as String),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      durationSeconds: map['duration_seconds'] as int?,
    );
  }
}

enum CommunicationType { call, sms }

/// Aggregated view: last communication per contact across all channels.
class ContactSummary {
  final String contactName;
  final String phoneNumber;
  final DateTime lastCommunication;
  final CommunicationType lastType;
  final Duration timeSinceLastContact;
  final int totalCalls;
  final int totalMessages;

  const ContactSummary({
    required this.contactName,
    required this.phoneNumber,
    required this.lastCommunication,
    required this.lastType,
    required this.timeSinceLastContact,
    required this.totalCalls,
    required this.totalMessages,
  });
}
