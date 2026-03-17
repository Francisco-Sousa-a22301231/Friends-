import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for storing communication records and consent data.
/// Data is stored locally on-device only (GDPR compliant - no cloud sync).
/// On web, uses in-memory storage for demo purposes.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  Database? _database;
  bool _initialized = false;

  // In-memory fallback for web
  final Map<String, List<Map<String, dynamic>>> _webStorage = {
    'communication_records': [],
    'gdpr_consent': [],
  };

  DatabaseService._();

  bool get isWeb => kIsWeb;

  Future<void> initialize() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'friends_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    _initialized = true;
  }

  Database get db {
    if (!_initialized || ((!kIsWeb) && _database == null)) {
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

  /// Insert for web fallback.
  Future<void> webInsert(String table, Map<String, dynamic> data) async {
    _webStorage[table]?.add(data);
  }

  /// Query for web fallback.
  List<Map<String, dynamic>> webQuery(String table) {
    return _webStorage[table] ?? [];
  }

  /// GDPR F5.5: Delete all user data.
  Future<void> deleteAllUserData() async {
    if (kIsWeb) {
      _webStorage['communication_records']?.clear();
      _webStorage['gdpr_consent']?.clear();
      return;
    }
    await db.delete('communication_records');
    await db.delete('gdpr_consent');
  }

  /// GDPR F5.5: Export all user data as a map.
  Future<Map<String, dynamic>> exportAllUserData() async {
    if (kIsWeb) {
      return {
        'communication_records': _webStorage['communication_records'],
        'gdpr_consent': _webStorage['gdpr_consent'],
        'exported_at': DateTime.now().toIso8601String(),
      };
    }

    final records = await db.query('communication_records');
    final consent = await db.query('gdpr_consent');

    return {
      'communication_records': records,
      'gdpr_consent': consent,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}
