import 'package:flutter_test/flutter_test.dart';
import 'package:friends_app/core/models/gdpr_consent.dart';

void main() {
  group('GdprConsent', () {
    test('default consent has all values as false', () {
      const consent = GdprConsent();

      expect(consent.callLogAccess, false);
      expect(consent.smsAccess, false);
      expect(consent.contactsAccess, false);
      expect(consent.dataStorageConsent, false);
      expect(consent.hasAllRequiredConsents, false);
    });

    test('hasAllRequiredConsents is true when all granted', () {
      const consent = GdprConsent(
        callLogAccess: true,
        smsAccess: true,
        contactsAccess: true,
        dataStorageConsent: true,
      );

      expect(consent.hasAllRequiredConsents, true);
    });

    test('hasAllRequiredConsents is false when one is missing', () {
      const consent = GdprConsent(
        callLogAccess: true,
        smsAccess: true,
        contactsAccess: false,
        dataStorageConsent: true,
      );

      expect(consent.hasAllRequiredConsents, false);
    });

    test('copyWith preserves unchanged values', () {
      const original = GdprConsent(callLogAccess: true);
      final updated = original.copyWith(smsAccess: true);

      expect(updated.callLogAccess, true);
      expect(updated.smsAccess, true);
      expect(updated.contactsAccess, false);
    });

    test('toMap and fromMap round-trip correctly', () {
      final consent = GdprConsent(
        callLogAccess: true,
        smsAccess: true,
        contactsAccess: true,
        dataStorageConsent: true,
        consentTimestamp: DateTime(2025, 6, 15),
      );

      final map = consent.toMap();
      final restored = GdprConsent.fromMap(map);

      expect(restored.callLogAccess, consent.callLogAccess);
      expect(restored.smsAccess, consent.smsAccess);
      expect(restored.contactsAccess, consent.contactsAccess);
      expect(restored.dataStorageConsent, consent.dataStorageConsent);
      expect(restored.consentTimestamp, consent.consentTimestamp);
    });
  });
}
