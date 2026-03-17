import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for storing communication records and consent data.
/// Data is stored locally on-device only (GDPR compliant - no cloud sync).
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  DatabaseService._();

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'friends_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Database get db {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE communication_records (
        id TEXT PRIMARY KEY,
        contact_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        duration_seconds INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE gdpr_consent (
        id INTEGER PRIMARY KEY DEFAULT 1,
        call_log_access INTEGER NOT NULL DEFAULT 0,
        sms_access INTEGER NOT NULL DEFAULT 0,
        contacts_access INTEGER NOT NULL DEFAULT 0,
        data_storage_consent INTEGER NOT NULL DEFAULT 0,
        consent_timestamp INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_records_phone ON communication_records(phone_number)
    ''');

    await db.execute('''
      CREATE INDEX idx_records_timestamp ON communication_records(timestamp DESC)
    ''');
  }

  /// GDPR F5.5: Delete all user data.
  Future<void> deleteAllUserData() async {
    await db.delete('communication_records');
    await db.delete('gdpr_consent');
  }

  /// GDPR F5.5: Export all user data as a map.
  Future<Map<String, dynamic>> exportAllUserData() async {
    final records = await db.query('communication_records');
    final consent = await db.query('gdpr_consent');

    return {
      'communication_records': records,
      'gdpr_consent': consent,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}
