import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DashboardDatabaseService {
  static const String _databaseName = 'dashboard_cache_v4.db';
  static const int _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;

    if (existingDatabase != null) {
      return existingDatabase;
    }

    _initializeDatabaseFactory();

    final openedDatabase = await _openDatabase();
    _database = openedDatabase;

    return openedDatabase;
  }

  void _initializeDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationSupportDirectory();
    final databasePath = path.join(directory.path, _databaseName);

    return databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      ),
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE dashboards (
      id TEXT PRIMARY KEY,
      theme TEXT,
      language TEXT,
      cached_at TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE dashboard_tabs (
      id TEXT PRIMARY KEY,
      dashboard_id TEXT NOT NULL,
      tab_index INTEGER NOT NULL,
      tab_name TEXT NOT NULL,
      cached_at TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_dashboard_tabs_dashboard_id_tab_index
    ON dashboard_tabs (dashboard_id, tab_index)
  ''');

    await _createDashboardTabWidgetsTable(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createDashboardTabWidgetsTable(db);
    }
  }

  Future<void> _createDashboardTabWidgetsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS dashboard_tab_widgets (
      id TEXT PRIMARY KEY,
      tab_id TEXT NOT NULL,
      widget_type TEXT NOT NULL,
      widget_index INTEGER NOT NULL,
      title TEXT NOT NULL,
      status TEXT NOT NULL,
      primary_value TEXT NOT NULL,
      description TEXT,
      cached_at TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_dashboard_tab_widgets_tab_id_widget_index
    ON dashboard_tab_widgets (tab_id, widget_index)
  ''');
  }
}
