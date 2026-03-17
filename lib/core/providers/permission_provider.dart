import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/gdpr_consent.dart';
import '../services/database_service.dart';

/// F5.1 & F5.2: Manages runtime permissions and GDPR consent state.
class PermissionProvider extends ChangeNotifier {
  bool _hasCompletedOnboarding = false;
  GdprConsent _consent = const GdprConsent();

  bool _callLogGranted = false;
  bool _smsGranted = false;
  bool _contactsGranted = false;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  GdprConsent get consent => _consent;
  bool get callLogGranted => _callLogGranted;
  bool get smsGranted => _smsGranted;
  bool get contactsGranted => _contactsGranted;

  bool get allPermissionsGranted =>
      _callLogGranted && _smsGranted && _contactsGranted;

  /// Check current permission status without requesting.
  Future<void> checkPermissions() async {
    _callLogGranted = await Permission.phone.isGranted;
    _smsGranted = await Permission.sms.isGranted;
    _contactsGranted = await Permission.contacts.isGranted;
    notifyListeners();
  }

  /// F5.1: Request call log permission with explanation.
  Future<bool> requestCallLogPermission() async {
    final status = await Permission.phone.request();
    _callLogGranted = status.isGranted;
    notifyListeners();
    return _callLogGranted;
  }

  /// F5.1: Request SMS permission with explanation.
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    _smsGranted = status.isGranted;
    notifyListeners();
    return _smsGranted;
  }

  /// F5.1: Request contacts permission with explanation.
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    _contactsGranted = status.isGranted;
    notifyListeners();
    return _contactsGranted;
  }

  /// F5.2: Record GDPR consent.
  Future<void> updateConsent(GdprConsent newConsent) async {
    _consent = newConsent.copyWith(consentTimestamp: DateTime.now());

    final db = DatabaseService.instance.db;
    await db.insert(
      'gdpr_consent',
      _consent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifyListeners();
  }

  /// Complete onboarding after permissions and consent are granted.
  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  /// Load saved consent from database.
  Future<void> loadSavedConsent() async {
    final db = DatabaseService.instance.db;
    final results = await db.query('gdpr_consent', limit: 1);
    if (results.isNotEmpty) {
      _consent = GdprConsent.fromMap(results.first);
      if (_consent.hasAllRequiredConsents) {
        _hasCompletedOnboarding = true;
      }
    }
    await checkPermissions();
    notifyListeners();
  }
}
