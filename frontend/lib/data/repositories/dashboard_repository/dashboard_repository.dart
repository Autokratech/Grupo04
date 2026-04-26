import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';

abstract class DashboardRepository {
  Future<List<DashboardPreset>> getAvailablePresets();

  Future<List<DashboardWidgetItem>> getDashboardItems({
    required String presetId,
  });

  Future<Dashboard> getDashboard();
  Future<List<DashboardTab>> getDashboardTabs({required String dashboardId});
  Future<List<DashboardWidgetItem>> getTabItems({required String tabId});
  Future<DashboardTab> createDashboardTab({required String dashboardId, required String name});
}