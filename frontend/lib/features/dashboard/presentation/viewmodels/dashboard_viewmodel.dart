import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  final DashboardPreferencesService _dashboardPreferencesService;

  DashboardViewModel({
    required DashboardRepository dashboardRepository,
    required DashboardPreferencesService dashboardPreferencesService,
  }) : _dashboardRepository = dashboardRepository,
       _dashboardPreferencesService = dashboardPreferencesService;

  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  List<DashboardWidgetItem> _items = [];
  List<DashboardWidgetItem> get items => List.unmodifiable(_items);
  void _clearItems() => _items = [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void _clearErrorMessage() => _errorMessage = null;

  List<DashboardPreset> _presets = [];
  List<DashboardPreset> get presets => List.unmodifiable(_presets);

  DashboardPreset? _selectedPreset;
  DashboardPreset? get selectedPreset => _selectedPreset;
  DashboardWidgetItem? _selectedItem;
  DashboardWidgetItem? get selectedItem => _selectedItem;
  void _clearSelectedItem() => _selectedItem = null;

  Future<void> initializeDashboard() async {
    _clearErrorMessage();

    try {
      _presets = await _dashboardRepository.getAvailablePresets();

      if (_presets.isEmpty) {
        _selectedPreset = null;
        _clearSelectedItem();
        _clearItems();
        await _dashboardPreferencesService.clearSelectedPresetId();
        _state = DashboardState.empty;
        notifyListeners();
        return;
      }

      final savedPresetId = _dashboardPreferencesService.selectedPresetId;

      DashboardPreset? savedPreset;
      for (final preset in _presets) {
        if (preset.id == savedPresetId) {
          savedPreset = preset;
          break;
        }
      }

      if (savedPreset != null) {
        _selectedPreset = savedPreset;
      } else {
        _selectedPreset = _presets.first;
        await _dashboardPreferencesService.saveSelectedPresetId(
          _selectedPreset!.id,
        );
      }

      await loadDashboard();
    } catch (_) {
      _presets = [];
      _selectedPreset = null;
      _clearSelectedItem();
      _clearItems();
      _state = DashboardState.error;
      _errorMessage = 'Ha ocurrido un error al inicializar el dashboard';
      notifyListeners();
    }
  }

  Future<void> changePreset(DashboardPreset preset) async {
    if (_selectedPreset?.id == preset.id) return;

    final presetExists = _presets.any(
      (currentPreset) => currentPreset.id == preset.id,
    );

    if (!presetExists) return;

    _selectedPreset = preset;
    await _dashboardPreferencesService.saveSelectedPresetId(preset.id);
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
