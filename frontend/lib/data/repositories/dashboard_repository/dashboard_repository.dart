import 'package:frontend/domain/models/dashboard_widget_item.dart';

abstract class DashboardRepository {
  Future<List<DashboardWidgetItem>> getDashboardItems({
    required String presetId,
  });
}