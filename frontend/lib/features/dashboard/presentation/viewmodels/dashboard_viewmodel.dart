import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
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

  Dashboard? _dashboard;
  Dashboard? get dashboard => _dashboard;

  List<DashboardTab> _tabs = [];
  List<DashboardTab> get tabs => List.unmodifiable(_tabs);
  DashboardTab? _selectedTab;
  DashboardTab? get selectedTab => _selectedTab;
  bool get canCreateTab => _tabs.length < AppConstants.maxTabs;

  DashboardWidgetItem? _selectedItem;
  DashboardWidgetItem? get selectedItem => _selectedItem;
  void _clearSelectedItem() => _selectedItem = null;

  Future<void> initializeDashboard() async {
    _clearErrorMessage();
    _state = DashboardState.loading;
    notifyListeners();

    try {
      _dashboard = await _dashboardRepository.getDashboard();

      _tabs = await _dashboardRepository.getDashboardTabs(
        dashboardId: _dashboard!.id,
      );

      if (_tabs.isEmpty) {
        _selectedTab = null;
        _clearSelectedItem();
        _clearItems();
        await _dashboardPreferencesService.clearSelectedTabId();
        _state = DashboardState.empty;
        notifyListeners();
        return;
      }

      final savedTabId = _dashboardPreferencesService.selectedTabId;

      DashboardTab? savedTab;
      for (final tab in _tabs) {
        if (tab.id == savedTabId) {
          savedTab = tab;
          break;
        }
      }

      if (savedTab != null) {
        _selectedTab = savedTab;
      } else {
        _selectedTab = _tabs.first;
        await _dashboardPreferencesService.saveSelectedTabId(_selectedTab!.id);
      }

      await loadTabItems();
    } catch (_) {
      _dashboard = null;
      _tabs = [];
      _selectedTab = null;
      _clearSelectedItem();
      _clearItems();
      _state = DashboardState.error;
      _errorMessage = 'Ha ocurrido un error al inicializar el dashboard';
      notifyListeners();
    }
  }

  Future<void> changeTab(DashboardTab tab) async {
    if (_selectedTab?.id == tab.id) return;

    final tabExists = _tabs.any((currentTab) => currentTab.id == tab.id);

    if (!tabExists) return;

    _selectedTab = tab;
    await _dashboardPreferencesService.saveSelectedTabId(tab.id);
    _clearSelectedItem();
    await loadTabItems();
  }

  Future<void> createTab(String name) async {
    final dashboard = _dashboard;

    if (dashboard == null) return;

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      _errorMessage = 'Introduce un nombre';
      notifyListeners();
      return;
    }

    if (!canCreateTab) {
      _errorMessage =
          'No se pueden crear más de ${AppConstants.maxTabs} dashboards';
      notifyListeners();
      return;
    }

    try {
      _clearErrorMessage();

      final createdTab = await _dashboardRepository.createDashboardTab(
        dashboardId: dashboard.id,
        name: normalizedName,
      );

      _tabs = await _dashboardRepository.getDashboardTabs(
        dashboardId: dashboard.id,
      );

      DashboardTab? selectedCreatedTab;
      for (final tab in _tabs) {
        if (tab.id == createdTab.id) {
          selectedCreatedTab = tab;
          break;
        }
      }

      _selectedTab = selectedCreatedTab ?? createdTab;

      await _dashboardPreferencesService.saveSelectedTabId(_selectedTab!.id);

      _clearSelectedItem();
      await loadTabItems();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al crear el dashboard';
      notifyListeners();
    }
  }

  Future<void> deleteTab(DashboardTab tab) async {
    final dashboard = _dashboard;

    if (dashboard == null) return;

    if (_tabs.length <= 1) {
      _errorMessage = 'Debe existir al menos un dashboard';
      notifyListeners();
      return;
    }

    try {
      _clearErrorMessage();

      final wasSelectedTab = _selectedTab?.id == tab.id;

      await _dashboardRepository.deleteDashboardTab(
        dashboardId: dashboard.id,
        tabId: tab.id,
      );

      _tabs = await _dashboardRepository.getDashboardTabs(
        dashboardId: dashboard.id,
      );

      if (_tabs.isEmpty) {
        _selectedTab = null;
        _clearSelectedItem();
        _clearItems();
        await _dashboardPreferencesService.clearSelectedTabId();
        _state = DashboardState.empty;
        notifyListeners();
        return;
      }

      if (wasSelectedTab) {
        _selectedTab = _tabs.first;
        await _dashboardPreferencesService.saveSelectedTabId(_selectedTab!.id);
      } else {
        final currentSelectedTabId = _selectedTab?.id;

        DashboardTab? stillExistingSelectedTab;
        for (final currentTab in _tabs) {
          if (currentTab.id == currentSelectedTabId) {
            stillExistingSelectedTab = currentTab;
            break;
          }
        }

        _selectedTab = stillExistingSelectedTab ?? _tabs.first;
        await _dashboardPreferencesService.saveSelectedTabId(_selectedTab!.id);
      }

      _clearSelectedItem();
      await loadTabItems();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al eliminar el dashboard';
      notifyListeners();
    }
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

  Future<void> loadTabItems() async {
    final dashboard = _dashboard;
    final selectedTab = _selectedTab;

    if (dashboard == null || selectedTab == null) {
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
          .getTabItems(dashboardId: dashboard.id, tabId: selectedTab.id);

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

  Future<void> reorderWidgets(List<DashboardWidgetItem> reorderedItems) async {
    final selectedTab = _selectedTab;

    if (selectedTab == null) return;

    try {
      _clearErrorMessage();

      _items = await _dashboardRepository.updateTabWidgetOrder(
        tabId: selectedTab.id,
        widgets: reorderedItems,
      );

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al reordenar los widgets';
      notifyListeners();
    }
  }
}
