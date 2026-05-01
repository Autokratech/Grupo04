import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';

abstract class DashboardRepository {
  Future<Dashboard> getDashboard();

  Future<List<DashboardTab>> getDashboardTabs({required String dashboardId});

  Future<DashboardTab> createDashboardTab({
    required String dashboardId,
    required String name,
  });

  Future<void> deleteDashboardTab({
    required String dashboardId,
    required String tabId,
  });

  Future<List<DashboardWidgetItem>> getTabItems({
    required String dashboardId,
    required String tabId,
  });

  Future<List<DashboardWidgetItem>> updateTabWidgetOrder({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  });
}
