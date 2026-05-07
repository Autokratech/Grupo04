import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';

abstract class DashboardRepository {
  Future<Dashboard> getDashboard();

  Future<List<DashboardTab>> getDashboardTabs({required String dashboardId});

  Future<DashboardTab> createDashboardTab({
    required String dashboardId,
    required String name,
  });

  Future<DashboardTab> renameDashboardTab({
    required String dashboardId,
    required String tabId,
    required String name,
  });

  Future<void> deleteDashboardTab({
    required String dashboardId,
    required String tabId,
  });

  Future<List<DashboardTab>> updateDashboardTabOrder({
    required String dashboardId,
    required List<DashboardTab> tabs,
  });

  Future<List<DashboardWidgetItem>> getTabItems({
    required String dashboardId,
    required String tabId,
  });

  Future<List<DashboardWidgetItem>> addTabWidget({
    required String tabId,
    required WidgetCatalogItem catalogItem,
  });

  Future<List<DashboardWidgetItem>> deleteTabWidget({
    required String tabId,
    required String widgetId,
  });

  Future<List<DashboardWidgetItem>> updateTabWidgetOrder({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  });
}