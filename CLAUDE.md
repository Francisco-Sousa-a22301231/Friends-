# CLAUDE.md

## Project Overview

**Friends App** — A Flutter mobile/web application that tracks how long it's been since you last communicated with friends and family. It monitors call logs and SMS messages to display a timeline of recent contact interactions.

- **Package name:** `friends_app` (v1.0.0+1)
- **Platforms:** Android, iOS, Web (web uses demo data)
- **Language:** Dart 3.2.0+
- **Framework:** Flutter (stable channel)

## Tech Stack

- **State Management:** Provider (`ChangeNotifier` pattern)
- **Database:** SQLite via `sqflite` (singleton `DatabaseService.instance`)
- **Native Access:** `call_log`, `flutter_sms_inbox`, `flutter_contacts`, `permission_handler`
- **Testing:** `flutter_test`, `mockito`, `build_runner`
- **Linting:** `flutter_lints` with custom rules in `analysis_options.yaml`

## Project Structure

```
lib/
├── main.dart                          # App entry point, routing
├── core/
│   ├── models/
│   │   ├── contact_communication.dart # CommunicationRecord, ContactSummary, CommunicationType enum
│   │   └── gdpr_consent.dart          # GdprConsent model
│   ├── providers/
│   │   ├── app_providers.dart         # Central provider registry
│   │   ├── contact_provider.dart      # Contact list state management
│   │   └── permission_provider.dart   # Permissions & GDPR consent state
│   └── services/
│       ├── database_service.dart      # SQLite operations (singleton)
│       ├── call_log_service.dart      # Call history access
│       ├── sms_service.dart           # SMS history access
│       └── contact_aggregator_service.dart  # Aggregates calls+SMS per contact
├── features/
│   ├── dashboard/
│   │   ├── screens/dashboard_screen.dart         # Main timeline view
│   │   └── widgets/
│   │       ├── contact_timeline_card.dart         # Contact card with urgency colors
│   │       └── empty_state_widget.dart            # Empty state UI
│   └── permissions/
│       ├── screens/onboarding_permissions_screen.dart  # Permission request stepper
│       └── widgets/
│           ├── permission_card.dart               # Permission request card
│           └── gdpr_consent_dialog.dart           # GDPR consent modal
test/
└── core/models/
    ├── contact_communication_test.dart
    └── gdpr_consent_test.dart
docs/                                  # Web build output for GitHub Pages
```

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run linting/static analysis
flutter analyze

# Run tests
flutter test

# Generate mocks (mockito)
dart run build_runner build

# Build targets
flutter build apk          # Android APK
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS
flutter build web           # Web
flutter build linux         # Linux
```

## Code Conventions

### Style Rules (enforced via `analysis_options.yaml`)

- **Single quotes** for strings (`'text'` not `"text"`)
- **Prefer `const` constructors** and const declarations
- **No `print` statements** — use proper logging/error handling
- Extends `package:flutter_lints/flutter.yaml`

### Architecture Patterns

- **Feature-based organization:** each feature has `screens/` and `widgets/` subdirectories
- **Core layer** (`core/`) contains models, providers, and services shared across features
- **Provider pattern:** state management via `ChangeNotifier` classes, registered centrally in `AppProviders.providers`
- **Singleton pattern:** `DatabaseService.instance` for database access
- **Platform guards:** use `kIsWeb` for web-specific behavior (demo data fallback)

### Data Models

- Implement `toMap()` / `fromMap()` for SQLite serialization
- Use `const` constructors and `copyWith()` for immutability
- Enum types for categorization (e.g., `CommunicationType { call, sms }`)

### Error Handling

- Try-catch in providers with error state fields
- Loading states tracked via boolean flags in providers
- User-facing error messages surfaced through provider state

## Database Schema

Two tables in local SQLite:

- **`communication_records`** — stores call/SMS history (id, contact_name, phone_number, type, timestamp, duration_seconds)
- **`gdpr_consent`** — stores per-type consent flags and timestamp

Indexes on `phone_number` and `timestamp DESC` for query performance.

## Privacy & GDPR

The app implements GDPR compliance:

- Granular consent toggles per data type (call logs, SMS, contacts, storage)
- Consent timestamps recorded
- Data export and deletion support
- All data stored locally on-device only (no cloud sync)
- Onboarding stepper flow ensures informed consent before data access

## Android Permissions

Required in `AndroidManifest.xml`:

- `READ_CALL_LOG`
- `READ_SMS`
- `READ_CONTACTS`

All requested at runtime via `permission_handler` with user-facing explanations.

## Deployment

- Web builds output to `docs/` for GitHub Pages hosting
- Use `flutter build web` then commit `docs/` changes
