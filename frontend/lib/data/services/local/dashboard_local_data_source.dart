import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';

abstract class DashboardLocalDataSource {
  Future<Dashboard?> getCachedDashboard({required String dashboardId});

  Future<void> cacheDashboard(Dashboard dashboard);

  Future<List<DashboardTab>> getCachedTabs({required String dashboardId});

  Future<void> cacheTabs({
    required String dashboardId,
    required List<DashboardTab> tabs,
  });

  Future<DashboardTab> createLocalTab({
    required String dashboardId,
    required String name,
  });

  Future<DashboardTab> renameLocalTab({
    required String dashboardId,
    required String tabId,
    required String name,
  });

  Future<void> deleteLocalTab({
    required String dashboardId,
    required String tabId,
  });

  Future<List<DashboardTab>> updateLocalTabOrder({
    required String dashboardId,
    required List<DashboardTab> tabs,
  });

  Future<List<DashboardWidgetItem>> getCachedTabWidgets({
    required String tabId,
  });

  Future<void> cacheTabWidgets({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  });
}
