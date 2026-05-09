import 'dart:convert';

import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_tab_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_tabs_response_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widgets_response_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/widget_catalog_item_dto.dart';
import 'package:frontend/data/services/remote/api_client.dart';
import 'package:http/http.dart' as http;

class DashboardApiService {
  static const Duration _requestTimeout = Duration(seconds: 5);
  static const Duration _widgetsStreamTimeout = Duration(seconds: 15);

  final ApiClient apiClient;

  const DashboardApiService({required this.apiClient});

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
    required int tabIndex,
  }) async {
    final response = await apiClient
        .post(_dashboardTabsEndpoint(dashboardId: dashboardId), {
          'tab_name': name.trim(),
          'tab_index': tabIndex,
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

  Future<DashboardTabDto> renameDashboardTab({
    required String dashboardId,
    required String tabId,
    required String name,
    required int tabIndex,
  }) async {
    final response = await apiClient
        .put(_dashboardTabEndpoint(dashboardId: dashboardId, tabId: tabId), {
          'tab_name': name.trim(),
          'tab_index': tabIndex,
        })
        .timeout(_requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseMap = _decodeObject(response.body);
      final tabMap = _extractTabFromCreateResponse(responseMap);
      return DashboardTabDto.fromMap(tabMap);
    }

    throw Exception(
      'Failed to rename dashboard tab: Status code ${response.statusCode}',
    );
  }

  Future<TabWidgetsResponseDto> getTabWidgets({
    required String dashboardId,
    required String tabId,
    required String userId,
  }) async {
    final response = await apiClient
        .getStream(
          _tabWidgetsEndpoint(
            dashboardId: dashboardId,
            tabId: tabId,
            userId: userId,
          ),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final responseMap = await _decodeWidgetsSse(
        response,
      ).timeout(_widgetsStreamTimeout);

      return TabWidgetsResponseDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to load dashboard widgets: Status code ${response.statusCode}',
    );
  }

  Future<List<WidgetCatalogItemDto>> getWidgetCatalog() async {
    final response = await apiClient
        .get(_widgetCatalogEndpoint())
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final responseList = _decodeList(response.body);

      return responseList
          .whereType<Map<String, dynamic>>()
          .map(WidgetCatalogItemDto.fromMap)
          .where((item) => item.id.trim().isNotEmpty)
          .toList();
    }

    throw Exception(
      'Failed to load widget catalog: Status code ${response.statusCode}',
    );
  }

  String _userDashboardEndpoint({required String userId}) {
    final encodedUserId = Uri.encodeQueryComponent(userId);
    return '/api/dashboard/?user_id=$encodedUserId';
  }

  String _dashboardTabsEndpoint({required String dashboardId}) {
    final encodedDashboardId = Uri.encodeComponent(dashboardId);
    return '/api/dashboard/$encodedDashboardId/tabs';
  }

  String _dashboardTabEndpoint({
    required String dashboardId,
    required String tabId,
  }) {
    final encodedDashboardId = Uri.encodeComponent(dashboardId);
    final encodedTabId = Uri.encodeComponent(tabId);

    return '/api/dashboard/$encodedDashboardId/tabs/$encodedTabId';
  }

  String _tabWidgetsEndpoint({
    required String dashboardId,
    required String tabId,
    required String userId,
  }) {
    final encodedDashboardId = Uri.encodeComponent(dashboardId);
    final encodedTabId = Uri.encodeComponent(tabId);
    final encodedUserId = Uri.encodeQueryComponent(userId);

    return '/api/dashboard/$encodedDashboardId/tabs/$encodedTabId/widgets?user_id=$encodedUserId';
  }

  String _widgetCatalogEndpoint() {
    return '/api/widgets/';
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Expected JSON object response');
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);

    if (decoded is List<dynamic>) {
      return decoded;
    }

    throw Exception('Expected JSON list response');
  }

  Map<String, dynamic> _extractTabFromCreateResponse(
    Map<String, dynamic> responseMap,
  ) {
    if (responseMap.containsKey('tab_id')) {
      return responseMap;
    }

    final data = responseMap['data'];

    if (data is List && data.isNotEmpty) {
      final firstItem = data.first;

      if (firstItem is Map<String, dynamic>) {
        return firstItem;
      }
    }

    throw Exception('Expected created tab inside response');
  }

  List<dynamic> _extractList(Map<String, dynamic>? map, String key) {
    final value = map?[key];

    if (value is List) {
      return value;
    }

    return const [];
  }

  Future<Map<String, dynamic>> _decodeWidgetsSse(
    http.StreamedResponse response,
  ) async {
    Map<String, dynamic>? skeletonEvent;
    Map<String, dynamic>? dataEvent;

    String? currentEvent;
    final dataBuffer = StringBuffer();

    void flushEvent() {
      final event = currentEvent;
      final data = dataBuffer.toString().trim();

      currentEvent = null;
      dataBuffer.clear();

      if (event == null || data.isEmpty) {
        return;
      }

      final decoded = jsonDecode(data);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Expected SSE data JSON object');
      }

      switch (event) {
        case 'widgets_skeleton':
          skeletonEvent = decoded;
          break;
        case 'widgets_data':
          dataEvent = decoded;
          break;
      }
    }

    await for (final rawLine
        in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      final line = rawLine.trimRight();

      if (line.isEmpty) {
        flushEvent();

        if (skeletonEvent != null && dataEvent != null) {
          break;
        }

        continue;
      }

      if (line.startsWith('event:')) {
        if (currentEvent != null && dataBuffer.isNotEmpty) {
          flushEvent();
        }

        currentEvent = line.substring('event:'.length).trim();
        continue;
      }

      if (line.startsWith('data:')) {
        final dataLine = line.substring('data:'.length).trimLeft();

        if (dataBuffer.isNotEmpty) {
          dataBuffer.write('\n');
        }

        dataBuffer.write(dataLine);
      }
    }

    flushEvent();

    return {
      'tab_widgets': _extractList(skeletonEvent, 'tab_widgets'),
      'tab_widgets_data': _extractList(dataEvent, 'tab_widgets_data'),
    };
  }
}
