import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
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

  int _tabItemsLoadVersion = 0;

  List<WidgetCatalogItem> _widgetCatalogItems = [];
  List<WidgetCatalogItem> get widgetCatalogItems {
    return List.unmodifiable(_widgetCatalogItems);
  }

  Future<void> _loadWidgetCatalog() async {
    _widgetCatalogItems = await _dashboardRepository.getWidgetCatalog();
  }

  List<WidgetCatalogItem> get availableWidgetCatalogItems {
    return widgetCatalogItems.where((catalogItem) {
      return !_isCatalogItemAlreadyAdded(catalogItem);
    }).toList();
  }

  bool get canAddWidget => availableWidgetCatalogItems.isNotEmpty;

  bool _isCatalogItemAlreadyAdded(WidgetCatalogItem catalogItem) {
    return _items.any((item) {
      return item.id == catalogItem.id ||
          item.id.endsWith('_${catalogItem.id}');
    });
  }

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
      final dashboard = await _dashboardRepository.getDashboard();
      _dashboard = dashboard;

      await _loadWidgetCatalog();

      _tabs = await _dashboardRepository.getDashboardTabs(
        dashboardId: dashboard.id,
      );

      if (_tabs.isEmpty) {
        _selectedTab = null;
        _clearSelectedItem();
        _clearItems();

        await _dashboardPreferencesService.clearSelectedTabId(
          dashboardId: dashboard.id,
        );

        _state = DashboardState.empty;
        notifyListeners();
        return;
      }

      final savedTabId = _dashboardPreferencesService.getSelectedTabId(
        dashboardId: dashboard.id,
      );

      final savedTab = _findTabById(savedTabId);

      if (savedTab != null) {
        _selectedTab = savedTab;
      } else {
        _selectedTab = _tabs.first;

        await _dashboardPreferencesService.saveSelectedTabId(
          dashboardId: dashboard.id,
          tabId: _selectedTab!.id,
        );
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

  DashboardTab? _findTabById(String? tabId) {
    if (tabId == null) return null;

    for (final tab in _tabs) {
      if (tab.id == tabId) {
        return tab;
      }
    }

    return null;
  }

  bool _hasSameTabIds(List<DashboardTab> otherTabs) {
    if (otherTabs.length != _tabs.length) {
      return false;
    }

    final currentIds = _tabs.map((tab) => tab.id).toSet();
    final otherIds = otherTabs.map((tab) => tab.id).toSet();

    return currentIds.containsAll(otherIds) && otherIds.containsAll(currentIds);
  }

  Future<void> changeTab(DashboardTab tab) async {
    final dashboard = _dashboard;

    if (dashboard == null) return;

    if (_selectedTab?.id == tab.id) return;

    final existingTab = _findTabById(tab.id);

    if (existingTab == null) return;

    _selectedTab = existingTab;

    await _dashboardPreferencesService.saveSelectedTabId(
      dashboardId: dashboard.id,
      tabId: existingTab.id,
    );

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

      final selectedCreatedTab = _findTabById(createdTab.id);
      _selectedTab = selectedCreatedTab ?? createdTab;

      await _dashboardPreferencesService.saveSelectedTabId(
        tabId: _selectedTab!.id,
        dashboardId: dashboard.id,
      );

      _clearSelectedItem();
      await loadTabItems();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al crear el dashboard';
      notifyListeners();
    }
  }

  Future<void> renameTab({
    required DashboardTab tab,
    required String name,
  }) async {
    final dashboard = _dashboard;

    if (dashboard == null) return;

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      _errorMessage = 'Introduce un nombre';
      notifyListeners();
      return;
    }

    final existingTab = _findTabById(tab.id);

    if (existingTab == null) return;

    try {
      _clearErrorMessage();

      final renamedTab = await _dashboardRepository.renameDashboardTab(
        dashboardId: dashboard.id,
        tabId: tab.id,
        name: normalizedName,
      );

      _tabs = _tabs.map((currentTab) {
        if (currentTab.id == renamedTab.id) {
          return renamedTab;
        }

        return currentTab;
      }).toList()..sort((a, b) => a.position.compareTo(b.position));

      if (_selectedTab?.id == renamedTab.id) {
        final updatedSelectedTab = _findTabById(renamedTab.id);

        if (updatedSelectedTab != null) {
          _selectedTab = updatedSelectedTab;

          await _dashboardPreferencesService.saveSelectedTabId(
            dashboardId: dashboard.id,
            tabId: updatedSelectedTab.id,
          );
        }
      }

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al renombrar el dashboard';
      notifyListeners();
    }
  }

  Future<void> reorderTabs(List<DashboardTab> reorderedTabs) async {
    final dashboard = _dashboard;
    final selectedTab = _selectedTab;

    if (dashboard == null) return;

    if (reorderedTabs.isEmpty) {
      _errorMessage = 'Debe existir al menos un dashboard';
      notifyListeners();
      return;
    }

    if (!_hasSameTabIds(reorderedTabs)) {
      _errorMessage = 'No se ha podido reordenar los dashboards';
      notifyListeners();
      return;
    }

    try {
      _clearErrorMessage();

      _tabs = await _dashboardRepository.updateDashboardTabOrder(
        dashboardId: dashboard.id,
        tabs: reorderedTabs,
      );

      if (selectedTab != null) {
        _selectedTab = _findTabById(selectedTab.id);

        if (_selectedTab != null) {
          await _dashboardPreferencesService.saveSelectedTabId(
            dashboardId: dashboard.id,
            tabId: _selectedTab!.id,
          );
        }
      }

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al reordenar los dashboards';
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
        await _dashboardPreferencesService.clearSelectedTabId(
          dashboardId: dashboard.id,
        );
        _state = DashboardState.empty;
        notifyListeners();
        return;
      }

      if (wasSelectedTab) {
        _selectedTab = _tabs.first;
        await _dashboardPreferencesService.saveSelectedTabId(
          tabId: _selectedTab!.id,
          dashboardId: dashboard.id,
        );
      } else {
        final currentSelectedTabId = _selectedTab?.id;
        final stillExistingSelectedTab = _findTabById(currentSelectedTabId);

        _selectedTab = stillExistingSelectedTab ?? _tabs.first;

        await _dashboardPreferencesService.saveSelectedTabId(
          tabId: _selectedTab!.id,
          dashboardId: dashboard.id,
        );
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
    final loadVersion = ++_tabItemsLoadVersion;

    if (dashboard == null || selectedTab == null) {
      _clearSelectedItem();
      _clearItems();
      _clearErrorMessage();
      _state = DashboardState.empty;
      notifyListeners();
      return;
    }

    final dashboardId = dashboard.id;
    final tabId = selectedTab.id;

    _clearErrorMessage();
    _state = DashboardState.loading;
    notifyListeners();

    try {
      final List<DashboardWidgetItem> items = await _dashboardRepository
          .getTabItems(dashboardId: dashboardId, tabId: tabId);

      if (loadVersion != _tabItemsLoadVersion) {
        return;
      }

      if (_selectedTab?.id != tabId || _dashboard?.id != dashboardId) {
        return;
      }

      if (items.isEmpty) {
        _clearSelectedItem();
        _clearItems();
        _state = DashboardState.empty;
      } else {
        _items = items;
        _state = DashboardState.loaded;
      }
    } catch (_) {
      if (loadVersion != _tabItemsLoadVersion) {
        return;
      }

      if (_selectedTab?.id != tabId || _dashboard?.id != dashboardId) {
        return;
      }

      _clearSelectedItem();
      _clearItems();
      _state = DashboardState.error;
      _errorMessage = 'Ha ocurrido un error al cargar el dashboard';
    }

    notifyListeners();
  }

  Future<void> addWidget(WidgetCatalogItem catalogItem) async {
    final selectedTab = _selectedTab;

    if (selectedTab == null) return;

    final catalogItemExists = _widgetCatalogItems.any(
      (item) => item.id == catalogItem.id,
    );

    if (!catalogItemExists) return;

    try {
      _clearErrorMessage();

      _items = await _dashboardRepository.addTabWidget(
        tabId: selectedTab.id,
        catalogItem: catalogItem,
      );

      _state = DashboardState.loaded;
      _clearSelectedItem();

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al añadir el widget';
      notifyListeners();
    }
  }

  Future<void> deleteWidget(DashboardWidgetItem widget) async {
    final selectedTab = _selectedTab;

    if (selectedTab == null) return;

    final existingWidget = _items.any((item) => item.id == widget.id);

    if (!existingWidget) return;

    try {
      _clearErrorMessage();

      _items = await _dashboardRepository.deleteTabWidget(
        tabId: selectedTab.id,
        widgetId: widget.id,
      );

      if (_selectedItem?.id == widget.id) {
        _clearSelectedItem();
      }

      _state = _items.isEmpty ? DashboardState.empty : DashboardState.loaded;

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al eliminar el widget';
      notifyListeners();
    }
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
