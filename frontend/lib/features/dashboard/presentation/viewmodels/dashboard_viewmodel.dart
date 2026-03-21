import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  List<DashboardWidgetItem> _items = [];
  List<DashboardWidgetItem> get items => List.unmodifiable(_items);
  void _clearItems() => _items = [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void _clearErrorMessage() => _errorMessage = null;

  Future<void> loadDashboard() async {
    _clearErrorMessage();
    _state = DashboardState.loading;
    notifyListeners();

    try {
      final List<DashboardWidgetItem> items = _fetchDashboardItems();

      if (items.isEmpty) {
        _clearItems();
        _state = DashboardState.empty;
      } else {
        _items = items;
        _state = DashboardState.loaded;
      }
    } catch (_) {
      _clearItems();
      _state = DashboardState.error;
      _errorMessage = 'An error occurred while loading the dashboard';
    }

    notifyListeners();
  }

  List<DashboardWidgetItem> _fetchDashboardItems() {
    return [
      DashboardWidgetItem(
        id: '1',
        title: 'Temperature',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '25°C',
      ),
      DashboardWidgetItem(
        id: '2',
        title: 'Humidity',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '60%',
      ),
      DashboardWidgetItem(
        id: '3',
        title: 'Battery',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: '100%',
      ),
    ];
  }
}
