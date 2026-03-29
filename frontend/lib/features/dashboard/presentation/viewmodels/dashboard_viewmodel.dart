import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
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

  final List<DashboardPreset> _presets = const [
    DashboardPreset(id: 'default', name: 'Por defecto'),
    DashboardPreset(id: 'operations', name: 'Operaciones'),
    DashboardPreset(id: 'pc_resources', name: 'Recursos PC'),
  ];
  List<DashboardPreset> get presets => List.unmodifiable(_presets);

  DashboardPreset? _selectedPreset;
  DashboardPreset? get selectedPreset => _selectedPreset;

  Future<void> initializeDashboard() async {
    _selectedPreset ??= _presets.first;
    await _loadDashboardForSelectedPreset();
  }

  Future<void> changePreset(DashboardPreset preset) async {
    _selectedPreset = preset;
    await _loadDashboardForSelectedPreset();
  }

  Future<void> _loadDashboardForSelectedPreset() async {
    _clearErrorMessage();
    _state = DashboardState.loading;
    notifyListeners();

    try {
      final List<DashboardWidgetItem> items = _fetchDashboardItemsForPreset(_selectedPreset!);

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
      _errorMessage = 'Ha ocurrido un error al cargar el dashboard';
    }

    notifyListeners();
  }

  List<DashboardWidgetItem> _fetchDashboardItemsForPreset(DashboardPreset preset) {
    switch (preset.id) {
      case 'default':
        return [
          DashboardWidgetItem(
            id: '1',
            title: 'Temperature',
            type: WidgetType.metric,
            status: WidgetStatus.ok,
            primaryValue: '25°C',
          ),
        ];

      case 'operations':
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
        ];

      case 'pc_resources':
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

      default:
        return [];
    }
  }
}
