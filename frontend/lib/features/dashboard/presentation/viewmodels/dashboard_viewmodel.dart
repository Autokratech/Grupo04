import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  DashboardViewModel({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  List<DashboardWidgetItem> _items = [];
  List<DashboardWidgetItem> get items => List.unmodifiable(_items);
  void _clearItems() => _items = [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void _clearErrorMessage() => _errorMessage = null;

  DashboardPreset? _selectedPreset;
  DashboardPreset? get selectedPreset => _selectedPreset;

  DashboardWidgetItem? _selectedItem;
  DashboardWidgetItem? get selectedItem => _selectedItem;
  void _clearSelectedItem() => _selectedItem = null;

  final List<DashboardPreset> _presets = const [
    DashboardPreset(id: 'default', name: 'Por defecto'),
    DashboardPreset(id: 'operations', name: 'Operaciones'),
    DashboardPreset(id: 'pc_resources', name: 'Recursos PC'),
  ];
  List<DashboardPreset> get presets => List.unmodifiable(_presets);

  Future<void> initializeDashboard() async {
    if (_presets.isEmpty) {
      _selectedPreset = null;
      _clearSelectedItem();
      _clearItems();
      _clearErrorMessage();
      _state = DashboardState.empty;
      notifyListeners();
      return;
    }

    _selectedPreset ??= _presets.first;
    await loadDashboard();
  }

  Future<void> changePreset(DashboardPreset preset) async {
    if (_selectedPreset?.id == preset.id) return;

    _selectedPreset = preset;
    _clearSelectedItem();
    await loadDashboard();
  }

  void selectItem(DashboardWidgetItem item) {
    if (_selectedItem?.id == item.id) return;

    _selectedItem = item;
    notifyListeners();
  }

  void clearSelectedItem() {
    if (_selectedItem == null) return;

    _clearSelectedItem();
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    final selectedPreset = _selectedPreset;

    if (selectedPreset == null) {
      _clearSelectedItem();
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
      final List<DashboardWidgetItem> items = await _dashboardRepository
          .getDashboardItems(presetId: selectedPreset.id);

      if (items.isEmpty) {
        _clearSelectedItem();
        _clearItems();
        _state = DashboardState.empty;
      } else {
        _items = items;
        _state = DashboardState.loaded;
      }
    } catch (_) {
      _clearSelectedItem();
      _clearItems();
      _state = DashboardState.error;
      _errorMessage = 'Ha ocurrido un error al cargar el dashboard';
    }

    notifyListeners();
  }
}
