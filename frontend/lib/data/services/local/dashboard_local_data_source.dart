import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/services/local/dashboard_database_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:sqflite/sqflite.dart';

class DashboardLocalDataSource {
  static const int _maxTabs = AppConstants.maxTabs;

  final DashboardDatabaseService databaseService;

  DashboardLocalDataSource({
    required this.databaseService,
  });

  Future<Dashboard?> getCachedDashboard() async {
    final db = await databaseService.database;

    final rows = await db.query(
      'dashboards',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _dashboardFromRow(rows.first);
  }

  Dashboard _dashboardFromRow(Map<String, Object?> row) {
    return Dashboard(
      id: row['id'] as String,
      theme: row['theme'] as String?,
      language: row['language'] as String?,
    );
  }

  Future<void> cacheDashboard(Dashboard dashboard) async {
    final db = await databaseService.database;

    await db.insert(
      'dashboards',
      _dashboardToRow(dashboard),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _dashboardToRow(Dashboard dashboard) {
    return {
      'id': dashboard.id,
      'theme': dashboard.theme,
      'language': dashboard.language,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  Future<List<DashboardTab>> getCachedTabs({
    required String dashboardId,
  }) async {
    final db = await databaseService.database;

    final rows = await db.query(
      'dashboard_tabs',
      where: 'dashboard_id = ?',
      whereArgs: [dashboardId],
      orderBy: 'tab_index ASC',
    );

    return rows.map(_dashboardTabFromRow).toList();
  }

  DashboardTab _dashboardTabFromRow(Map<String, Object?> row) {
    return DashboardTab(
      id: row['id'] as String,
      name: row['tab_name'] as String,
      position: row['tab_index'] as int,
    );
  }

  Future<void> cacheTabs({
    required String dashboardId,
    required List<DashboardTab> tabs,
  }) async {
    final db = await databaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'dashboard_tabs',
        where: 'dashboard_id = ?',
        whereArgs: [dashboardId],
      );

      for (final tab in tabs) {
        await transaction.insert(
          'dashboard_tabs',
          _dashboardTabToRow(
            dashboardId: dashboardId,
            tab: tab,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Map<String, Object?> _dashboardTabToRow({
    required String dashboardId,
    required DashboardTab tab,
  }) {
    return {
      'id': tab.id,
      'dashboard_id': dashboardId,
      'tab_index': tab.position,
      'tab_name': tab.name,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  Future<DashboardTab> createLocalTab({
    required String dashboardId,
    required String name,
  }) async {
    final db = await databaseService.database;

    return db.transaction((transaction) async {
      final countRows = await transaction.rawQuery(
        '''
      SELECT COUNT(*) AS total
      FROM dashboard_tabs
      WHERE dashboard_id = ?
      ''',
        [dashboardId],
      );

      final totalTabs = countRows.first['total'] as int;

      if (totalTabs >= _maxTabs) {
        throw StateError('No se pueden crear más de $_maxTabs dashboards.');
      }

      final positionRows = await transaction.rawQuery(
        '''
      SELECT MAX(tab_index) AS max_position
      FROM dashboard_tabs
      WHERE dashboard_id = ?
      ''',
        [dashboardId],
      );

      final maxPosition = positionRows.first['max_position'] as int?;
      final nextPosition = (maxPosition ?? -1) + 1;

      final tab = DashboardTab(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        position: nextPosition,
      );

      await transaction.insert(
        'dashboard_tabs',
        _dashboardTabToRow(
          dashboardId: dashboardId,
          tab: tab,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return tab;
    });
  }
}