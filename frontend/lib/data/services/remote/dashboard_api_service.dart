import 'dart:convert';
import 'package:frontend/data/models/dto/dashboard_dto.dart';
import 'package:frontend/data/models/dto/dashboard_tab_dto.dart';
import 'package:frontend/data/models/dto/dashboard_tabs_response_dto.dart';
import 'package:frontend/data/models/dto/tab_widgets_response_dto.dart';
import 'package:frontend/data/services/remote/api_client.dart';

class DashboardApiService {
  static const Duration _requestTimeout = Duration(seconds: 4);
  final ApiClient apiClient;

  const DashboardApiService({required this.apiClient});

  String _userDashboardEndpoint({required String userId}) {
    final encodedUserId = Uri.encodeQueryComponent(userId);
    return '/api/dashboard/?user_id=$encodedUserId';
  }

  String _dashboardTabsEndpoint({required String dashboardId}) {
    final encodedDashboardId = Uri.encodeComponent(dashboardId);
    return '/api/dashboard/$encodedDashboardId/tabs';
  }

  String _tabWidgetsEndpoint({
    required String dashboardId,
    required String tabId,
  }) {
    final encodedDashboardId = Uri.encodeComponent(dashboardId);
    final encodedTabId = Uri.encodeComponent(tabId);

    return '/api/dashboard/$encodedDashboardId/tabs/$encodedTabId/widgets';
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Expected JSON object response');
  }

  Map<String, dynamic> _extractTabFromCreateResponse(
    Map<String, dynamic> responseMap,
  ) {
    final data = responseMap['data'];

    if (data is List && data.isNotEmpty) {
      final firstItem = data.first;

      if (firstItem is Map<String, dynamic>) {
        return firstItem;
      }
    }

    throw Exception('Expected created tab inside data[0]');
  }

  Future<DashboardDto> getUserDashboard({required String userId}) async {
    final response = await apiClient
        .get(_userDashboardEndpoint(userId: userId))
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final responseMap = _decodeObject(response.body);
      return DashboardDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to load user dashboard: Status code ${response.statusCode}',
    );
  }

  Future<DashboardTabsResponseDto> getDashboardTabs({
    required String dashboardId,
  }) async {
    final response = await apiClient
        .get(_dashboardTabsEndpoint(dashboardId: dashboardId))
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final responseMap = _decodeObject(response.body);
      return DashboardTabsResponseDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to load dashboard tabs: Status code ${response.statusCode}',
    );
  }

  Future<DashboardTabDto> createDashboardTab({
    required String dashboardId,
    required String name,
  }) async {
    final response = await apiClient
        .post(_dashboardTabsEndpoint(dashboardId: dashboardId), {
          'tab_name': name.trim(),
        })
        .timeout(_requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseMap = _decodeObject(response.body);
      final tabMap = _extractTabFromCreateResponse(responseMap);
      return DashboardTabDto.fromMap(tabMap);
    }

    throw Exception(
      'Failed to create dashboard tab: Status code ${response.statusCode}',
    );
  }

  Future<TabWidgetsResponseDto> getTabWidgets({
    required String dashboardId,
    required String tabId,
  }) async {
    final response = await apiClient
        .get(_tabWidgetsEndpoint(dashboardId: dashboardId, tabId: tabId))
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final responseMap = _decodeObject(response.body);
      return TabWidgetsResponseDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to load dashboard widgets: Status code ${response.statusCode}',
    );
  }
}
