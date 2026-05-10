import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/storage/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_add_option.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  static const Duration _tabRefreshCooldown = Duration(seconds: 32);
  static const Duration _globalRefreshCooldown = Duration(seconds: 32);

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

  final Map<String, List<DashboardWidgetItem>> _itemsByTabId = {};
  final Map<String, DateTime> _lastRemoteRefreshByTabId = {};
  DateTime? _lastGlobalRemoteRefresh;

  int _tabItemsLoadVersion = 0;

  List<WidgetCatalogItem> _widgetCatalogItems = [];
  List<WidgetCatalogItem> get widgetCatalogItems {
    return List.unmodifiable(_widgetCatalogItems);
  }

  Future<void> _loadWidgetCatalog() async {
    _widgetCatalogItems = await _dashboardRepository.getWidgetCatalog();
  }

  List<WidgetCatalogItem> get availableWidgetCatalogItems {
    return List.unmodifiable(_widgetCatalogItems);
  }

  bool get canAddWidget => availableWidgetCatalogItems.isNotEmpty;

  bool isWidgetAddOptionAlreadyAdded(WidgetAddOption option) {
    final optionProvider = _normalizeProvider(option.providerName);
    final optionDataType = _normalizeDataType(option.dataType);

    return _items.any((item) {
      final itemProvider = _normalizeProvider(item.provider);
      final itemDataType = _normalizeDataType(item.dataType);

      return itemProvider == optionProvider && itemDataType == optionDataType;
    });
  }

  String _normalizeProvider(String? provider) {
    return provider?.trim().toLowerCase() ?? '';
  }

  String _normalizeDataType(String? dataType) {
    return dataType?.trim().toUpperCase() ?? '';
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

  bool _shouldRefreshTab(String tabId) {
    final lastRefresh = _lastRemoteRefreshByTabId[tabId];

    if (lastRefresh == null) {
      return true;
    }

    return DateTime.now().difference(lastRefresh) >= _tabRefreshCooldown;
  }

  bool _shouldRefreshGlobally() {
    final lastRefresh = _lastGlobalRemoteRefresh;

    if (lastRefresh == null) {
      return true;
    }

    return DateTime.now().difference(lastRefresh) >= _globalRefreshCooldown;
  }

  void _markTabAsRefreshed(String tabId) {
    _lastRemoteRefreshByTabId[tabId] = DateTime.now();
  }

  void _markGlobalRefresh() {
    _lastGlobalRemoteRefresh = DateTime.now();
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

      _tabs = [..._tabs.where((tab) => tab.id != createdTab.id), createdTab]
        ..sort((a, b) => a.position.compareTo(b.position));

      _selectedTab = _findTabById(createdTab.id) ?? createdTab;

      await _dashboardPreferencesService.saveSelectedTabId(
        tabId: _selectedTab!.id,
        dashboardId: dashboard.id,
      );

      _clearSelectedItem();
      _clearItems();
      _itemsByTabId[_selectedTab!.id] = const [];
      _lastRemoteRefreshByTabId.remove(_selectedTab!.id);
      _state = DashboardState.empty;

      notifyListeners();
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

      _itemsByTabId.remove(tab.id);
      _lastRemoteRefreshByTabId.remove(tab.id);

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
    final cachedItems = _itemsByTabId[tabId];

    final shouldRefreshRemote =
        cachedItems == null ||
        (_shouldRefreshTab(tabId) && _shouldRefreshGlobally());

    _clearErrorMessage();

    if (cachedItems != null) {
      _items = List<DashboardWidgetItem>.from(cachedItems);
      _state = _items.isEmpty ? DashboardState.empty : DashboardState.loaded;
      notifyListeners();

      if (!shouldRefreshRemote) {
        return;
      }
    } else {
      _state = DashboardState.loading;
      notifyListeners();
    }

    try {
      final remoteItems = await _dashboardRepository.getTabItems(
        dashboardId: dashboardId,
        tabId: tabId,
      );

      if (loadVersion != _tabItemsLoadVersion) {
        return;
      }

      if (_selectedTab?.id != tabId || _dashboard?.id != dashboardId) {
        return;
      }

      _markTabAsRefreshed(tabId);
      _markGlobalRefresh();

      _itemsByTabId[tabId] = List<DashboardWidgetItem>.from(remoteItems);

      if (remoteItems.isEmpty) {
        _clearSelectedItem();
        _clearItems();
        _state = DashboardState.empty;
      } else {
        _items = remoteItems;
        _state = DashboardState.loaded;
      }
    } catch (_) {
      if (loadVersion != _tabItemsLoadVersion) {
        return;
      }

      if (_selectedTab?.id != tabId || _dashboard?.id != dashboardId) {
        return;
      }

      if (cachedItems != null) {
        _items = List<DashboardWidgetItem>.from(cachedItems);
        _state = _items.isEmpty ? DashboardState.empty : DashboardState.loaded;
      } else {
        _clearSelectedItem();
        _clearItems();
        _state = DashboardState.error;
        _errorMessage = 'Ha ocurrido un error al cargar el dashboard';
      }
    }

    notifyListeners();
  }

  Future<void> addWidget({
    required WidgetCatalogItem catalogItem,
    required WidgetAddOption option,
  }) async {
    final dashboard = _dashboard;
    final selectedTab = _selectedTab;

    if (dashboard == null || selectedTab == null) return;

    final catalogItemExists = _widgetCatalogItems.any(
      (item) => item.id == catalogItem.id,
    );

    if (!catalogItemExists) return;

    if (isWidgetAddOptionAlreadyAdded(option)) {
      _errorMessage = 'Este widget ya existe en este dashboard';
      notifyListeners();
      return;
    }

    try {
      _clearErrorMessage();

      _items = await _dashboardRepository.addTabWidget(
        dashboardId: dashboard.id,
        tabId: selectedTab.id,
        catalogItem: catalogItem,
        option: option,
      );

      _itemsByTabId[selectedTab.id] = List<DashboardWidgetItem>.from(_items);
      _markTabAsRefreshed(selectedTab.id);
      _markGlobalRefresh();

      _state = _items.isEmpty ? DashboardState.empty : DashboardState.loaded;
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

      _itemsByTabId[selectedTab.id] = List<DashboardWidgetItem>.from(_items);

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

      _itemsByTabId[selectedTab.id] = List<DashboardWidgetItem>.from(_items);

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ha ocurrido un error al reordenar los widgets';
      notifyListeners();
    }
  }
}
