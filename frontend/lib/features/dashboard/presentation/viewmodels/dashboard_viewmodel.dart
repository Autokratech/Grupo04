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
    if (_presets.isEmpty) {
      _selectedPreset = null;
      _clearItems();
      _clearErrorMessage();
      _state = DashboardState.empty;
      notifyListeners();
      return;
    }

    _selectedPreset ??= _presets.first;
    await _loadDashboardForSelectedPreset();
  }

  Future<void> changePreset(DashboardPreset preset) async {
    if (_selectedPreset?.id == preset.id) return;

    _selectedPreset = preset;
    await _loadDashboardForSelectedPreset();
  }

  Future<void> _loadDashboardForSelectedPreset() async {
    final selectedPreset = _selectedPreset;

    if (selectedPreset == null) {
      _clearItems();
      _clearErrorMessage();
      _state = DashboardState.empty;
      notifyListeners();
      return;
    }

    _clearErrorMessage();
    _state = DashboardState.loading;
    notifyListeners();

    try {
      final List<DashboardWidgetItem> items = _fetchDashboardItemsForPreset(
        selectedPreset,
      );

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

  List<DashboardWidgetItem> _fetchDashboardItemsForPreset(
      DashboardPreset preset,
      ) {
    switch (preset.id) {
      case 'default':
        return [
          DashboardWidgetItem(
            id: 'active-services',
            title: 'Servicios activos',
            type: WidgetType.service,
            status: WidgetStatus.ok,
            primaryValue: '12',
          ),
          DashboardWidgetItem(
            id: 'open-incidents',
            title: 'Incidencias abiertas',
            type: WidgetType.alert,
            status: WidgetStatus.error,
            primaryValue: '3',
          ),
          DashboardWidgetItem(
            id: 'sync-status',
            title: 'Sincronización',
            type: WidgetType.status,
            status: WidgetStatus.ok,
            primaryValue: 'Operativa',
          ),
        ];

      case 'operations':
        return [
          DashboardWidgetItem(
            id: 'pending-forms',
            title: 'Formularios pendientes',
            type: WidgetType.alert,
            status: WidgetStatus.error,
            primaryValue: '8',
          ),
          DashboardWidgetItem(
            id: 'failed-services',
            title: 'Servicios con error',
            type: WidgetType.service,
            status: WidgetStatus.error,
            primaryValue: '2',
          ),
          DashboardWidgetItem(
            id: 'avg-response-time',
            title: 'Tiempo medio de respuesta',
            type: WidgetType.metric,
            status: WidgetStatus.ok,
            primaryValue: '240 ms',
          ),
        ];

      case 'pc_resources':
        return [
          DashboardWidgetItem(
            id: 'cpu-usage',
            title: 'Uso de CPU',
            type: WidgetType.metric,
            status: WidgetStatus.ok,
            primaryValue: '34%',
          ),
          DashboardWidgetItem(
            id: 'ram-usage',
            title: 'Uso de RAM',
            type: WidgetType.metric,
            status: WidgetStatus.ok,
            primaryValue: '68%',
          ),
          DashboardWidgetItem(
            id: 'disk-space',
            title: 'Espacio en disco',
            type: WidgetType.metric,
            status: WidgetStatus.ok,
            primaryValue: '120 GB',
          ),
          DashboardWidgetItem(
            id: 'network-status',
            title: 'Red',
            type: WidgetType.status,
            status: WidgetStatus.ok,
            primaryValue: 'Conectada',
          ),
        ];

      default:
        return [];
    }
  }
}
