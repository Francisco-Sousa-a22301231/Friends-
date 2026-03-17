/// Tracks the user's GDPR consent state.
class GdprConsent {
  final bool callLogAccess;
  final bool smsAccess;
  final bool contactsAccess;
  final bool dataStorageConsent;
  final DateTime? consentTimestamp;

  const GdprConsent({
    this.callLogAccess = false,
    this.smsAccess = false,
    this.contactsAccess = false,
    this.dataStorageConsent = false,
    this.consentTimestamp,
  });

  bool get hasAllRequiredConsents =>
      callLogAccess && smsAccess && contactsAccess && dataStorageConsent;

  GdprConsent copyWith({
    bool? callLogAccess,
    bool? smsAccess,
    bool? contactsAccess,
    bool? dataStorageConsent,
    DateTime? consentTimestamp,
  }) {
    return GdprConsent(
      callLogAccess: callLogAccess ?? this.callLogAccess,
      smsAccess: smsAccess ?? this.smsAccess,
      contactsAccess: contactsAccess ?? this.contactsAccess,
      dataStorageConsent: dataStorageConsent ?? this.dataStorageConsent,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'call_log_access': callLogAccess ? 1 : 0,
      'sms_access': smsAccess ? 1 : 0,
      'contacts_access': contactsAccess ? 1 : 0,
      'data_storage_consent': dataStorageConsent ? 1 : 0,
      'consent_timestamp': consentTimestamp?.millisecondsSinceEpoch,
    };
  }

  factory GdprConsent.fromMap(Map<String, dynamic> map) {
    return GdprConsent(
      callLogAccess: map['call_log_access'] == 1,
      smsAccess: map['sms_access'] == 1,
      contactsAccess: map['contacts_access'] == 1,
      dataStorageConsent: map['data_storage_consent'] == 1,
      consentTimestamp: map['consent_timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['consent_timestamp'] as int)
          : null,
    );
  }
}
