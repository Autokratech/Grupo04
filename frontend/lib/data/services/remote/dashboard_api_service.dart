import 'dart:convert';
import 'package:frontend/data/models/dto/tab_widgets_response_dto.dart';
import 'package:frontend/data/services/remote/api_client.dart';

class DashboardApiService {
  final ApiClient apiClient;

  const DashboardApiService({required this.apiClient});

  Future<TabWidgetsResponseDto> getTabWidgets({
    required String dashboardId,
    required String tabId,
  }) async {
    final response = await apiClient.get(
      _tabWidgetsEndpoint(dashboardId: dashboardId, tabId: tabId),
    );

    if (response.statusCode == 200) {
      final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
      return TabWidgetsResponseDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to load dashboard widgets: Status code ${response.statusCode}',
    );
  }

  String _tabWidgetsEndpoint({
    required String dashboardId,
    required String tabId,
  }) {
    return '/dashboard/$dashboardId/tabs/$tabId/widgets';
  }
}
