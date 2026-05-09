import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/services/local/dashboard_database_service.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDashboardLocalDataSource implements DashboardLocalDataSource {
  static const int _maxTabs = AppConstants.maxTabs;

  final DashboardDatabaseService databaseService;

  SQLiteDashboardLocalDataSource({required this.databaseService});

  @override
  Future<Dashboard?> getCachedDashboard({required String dashboardId}) async {
    final db = await databaseService.database;

    final rows = await db.query(
      'dashboards',
      where: 'id = ?',
      whereArgs: [dashboardId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _dashboardFromRow(rows.first);
  }

  @override
  Future<void> cacheDashboard(Dashboard dashboard) async {
    final db = await databaseService.database;

    await db.insert(
      'dashboards',
      _dashboardToRow(dashboard),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
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

  @override
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
          _dashboardTabToRow(dashboardId: dashboardId, tab: tab),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
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

      final normalizedName = name.trim();

      if (normalizedName.isEmpty) {
        throw StateError('Introduce un nombre');
      }

      final tab = DashboardTab(
        id: '${dashboardId}_local_${DateTime.now().microsecondsSinceEpoch}',
        name: normalizedName,
        position: nextPosition,
      );

      await transaction.insert(
        'dashboard_tabs',
        _dashboardTabToRow(dashboardId: dashboardId, tab: tab),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return tab;
    });
  }

  @override
  Future<DashboardTab> renameLocalTab({
    required String dashboardId,
    required String tabId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw StateError('Introduce un nombre');
    }

    final db = await databaseService.database;

    return db.transaction((transaction) async {
      final updatedRows = await transaction.update(
        'dashboard_tabs',
        {
          'tab_name': normalizedName,
          'cached_at': DateTime.now().toIso8601String(),
        },
        where: 'dashboard_id = ? AND id = ?',
        whereArgs: [dashboardId, tabId],
      );

      if (updatedRows == 0) {
        throw StateError('El dashboard no existe');
      }

      final rows = await transaction.query(
        'dashboard_tabs',
        where: 'dashboard_id = ? AND id = ?',
        whereArgs: [dashboardId, tabId],
        limit: 1,
      );

      return _dashboardTabFromRow(rows.first);
    });
  }

  @override
  Future<void> deleteLocalTab({
    required String dashboardId,
    required String tabId,
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

      if (totalTabs <= 1) {
        throw StateError('Debe existir al menos un dashboard');
      }

      final deletedRows = await transaction.delete(
        'dashboard_tabs',
        where: 'dashboard_id = ? AND id = ?',
        whereArgs: [dashboardId, tabId],
      );

      if (deletedRows == 0) {
        throw StateError('El dashboard no existe');
      }

      await transaction.delete(
        'dashboard_tab_widgets',
        where: 'tab_id = ?',
        whereArgs: [tabId],
      );

      final remainingRows = await transaction.query(
        'dashboard_tabs',
        where: 'dashboard_id = ?',
        whereArgs: [dashboardId],
        orderBy: 'tab_index ASC',
      );

      for (var index = 0; index < remainingRows.length; index++) {
        final row = remainingRows[index];

        await transaction.update(
          'dashboard_tabs',
          {
            'tab_index': index,
            'cached_at': DateTime.now().toIso8601String(),
          },
          where: 'dashboard_id = ? AND id = ?',
          whereArgs: [dashboardId, row['id']],
        );
      }
    });
  }

  @override
  Future<List<DashboardTab>> updateLocalTabOrder({
    required String dashboardId,
    required List<DashboardTab> tabs,
  }) async {
    if (tabs.isEmpty) {
      throw StateError('Debe existir al menos un dashboard');
    }

    final db = await databaseService.database;

    return db.transaction((transaction) async {
      final existingRows = await transaction.query(
        'dashboard_tabs',
        where: 'dashboard_id = ?',
        whereArgs: [dashboardId],
        orderBy: 'tab_index ASC',
      );

      final existingIds = existingRows.map((row) => row['id'] as String).toSet();
      final incomingIds = tabs.map((tab) => tab.id).toSet();

      final hasSameLength = existingRows.length == tabs.length;
      final hasNoDuplicateIncomingIds = incomingIds.length == tabs.length;
      final hasSameIds =
          existingIds.containsAll(incomingIds) &&
              incomingIds.containsAll(existingIds);

      if (!hasSameLength || !hasNoDuplicateIncomingIds || !hasSameIds) {
        throw StateError(
          'La lista de dashboards no coincide con el dashboard actual',
        );
      }

      final normalizedTabs = <DashboardTab>[];

      for (var index = 0; index < tabs.length; index++) {
        final normalizedTab = tabs[index].copyWith(position: index);
        normalizedTabs.add(normalizedTab);

        await transaction.update(
          'dashboard_tabs',
          {
            'tab_index': normalizedTab.position,
            'cached_at': DateTime.now().toIso8601String(),
          },
          where: 'dashboard_id = ? AND id = ?',
          whereArgs: [dashboardId, normalizedTab.id],
        );
      }

      return normalizedTabs;
    });
  }

  @override
  Future<List<DashboardWidgetItem>> getCachedTabWidgets({
    required String tabId,
  }) async {
    final db = await databaseService.database;

    final rows = await db.query(
      'dashboard_tab_widgets',
      where: 'tab_id = ?',
      whereArgs: [tabId],
      orderBy: 'widget_index ASC',
    );

    return rows.map(_dashboardWidgetFromRow).toList();
  }

  @override
  Future<void> cacheTabWidgets({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  }) async {
    final db = await databaseService.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'dashboard_tab_widgets',
        where: 'tab_id = ?',
        whereArgs: [tabId],
      );

      final sortedWidgets = [...widgets]
        ..sort((a, b) => a.position.compareTo(b.position));

      for (final widget in sortedWidgets) {
        await transaction.insert(
          'dashboard_tab_widgets',
          _dashboardWidgetToRow(tabId: tabId, widget: widget),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Dashboard _dashboardFromRow(Map<String, Object?> row) {
    return Dashboard(
      id: row['id'] as String,
      theme: row['theme'] as String?,
      language: row['language'] as String?,
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

  DashboardTab _dashboardTabFromRow(Map<String, Object?> row) {
    return DashboardTab(
      id: row['id'] as String,
      name: row['tab_name'] as String,
      position: row['tab_index'] as int,
    );
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

  DashboardWidgetItem _dashboardWidgetFromRow(Map<String, Object?> row) {
    return DashboardWidgetItem(
      id: row['id'] as String,
      title: row['title'] as String,
      type: _widgetTypeFromName(row['widget_type']),
      status: _widgetStatusFromName(row['status']),
      primaryValue: row['primary_value'] as String,
      description: row['description'] as String?,
      position: row['widget_index'] as int,
    );
  }

  Map<String, Object?> _dashboardWidgetToRow({
    required String tabId,
    required DashboardWidgetItem widget,
  }) {
    return {
      'id': widget.id,
      'tab_id': tabId,
      'widget_type': widget.type.name,
      'widget_index': widget.position,
      'title': widget.title,
      'status': widget.status.name,
      'primary_value': widget.primaryValue,
      'description': widget.description,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  WidgetType _widgetTypeFromName(Object? value) {
    final name = value?.toString();

    for (final type in WidgetType.values) {
      if (type.name == name) {
        return type;
      }
    }

    return WidgetType.status;
  }

  WidgetStatus _widgetStatusFromName(Object? value) {
    final name = value?.toString();

    for (final status in WidgetStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return WidgetStatus.inactive;
  }
}