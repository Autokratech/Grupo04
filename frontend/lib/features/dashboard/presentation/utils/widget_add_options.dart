import 'package:frontend/domain/models/widget_add_option.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';

List<WidgetAddOption> optionsForWidgetCatalogItem(WidgetCatalogItem item) {
  final title = _normalize(item.title);

  if (_containsAny(title, ['git projects', 'list user repositories'])) {
    return const [
      WidgetAddOption(
        label: 'GitHub · Proyectos',
        providerName: 'github',
        dataType: 'PROJECTS',
      ),
      WidgetAddOption(
        label: 'GitLab · Proyectos',
        providerName: 'gitlab',
        dataType: 'PROJECTS',
      ),
    ];
  }

  if (_containsAny(title, ['issue tracker', 'issue list'])) {
    return const [
      WidgetAddOption(
        label: 'GitHub · Issues',
        providerName: 'github',
        dataType: 'ISSUES',
      ),
      WidgetAddOption(
        label: 'GitLab · Issues',
        providerName: 'gitlab',
        dataType: 'ISSUES',
      ),
    ];
  }

  if (_containsAny(title, ['merge request tracker', 'merge request list'])) {
    return const [
      WidgetAddOption(
        label: 'GitLab · Merge requests',
        providerName: 'gitlab',
        dataType: 'MERGE_REQUESTS',
      ),
    ];
  }

  if (_containsAny(title, ['virtual machines'])) {
    return const [
      WidgetAddOption(
        label: 'Azure · Virtual machines',
        providerName: 'azure',
        dataType: 'VIRTUAL_MACHINES',
      ),
      WidgetAddOption(
        label: 'GCP · Virtual machines',
        providerName: 'gcp',
        dataType: 'VIRTUAL_MACHINES',
      ),
    ];
  }

  if (_containsAny(title, ['key vault', 'key vaults'])) {
    return const [
      WidgetAddOption(
        label: 'Azure · Key Vaults',
        providerName: 'azure',
        dataType: 'KEY_VAULTS',
      ),
    ];
  }

  if (_containsAny(title, ['resource groups'])) {
    return const [
      WidgetAddOption(
        label: 'Azure · Resource groups',
        providerName: 'azure',
        dataType: 'RESOURCE_GROUPS',
      ),
    ];
  }

  if (_containsAny(title, ['cost management'])) {
    return const [
      WidgetAddOption(
        label: 'Azure · Cost management',
        providerName: 'azure',
        dataType: 'COST_MANAGEMENT',
        customConfig: {
          'type': 'Usage',
          'dataset': {
            'grouping': [
              {'name': 'ServiceFamily', 'type': 'Dimension'},
            ],
            'aggregation': {
              'totalCost': {'name': 'Cost', 'function': 'Sum'},
            },
            'granularity': 'None',
          },
          'timeframe': 'MonthToDate',
        },
      ),
    ];
  }

  // De momento no activamos agentes porque falta selección de agent_id.
  if (_containsAny(title, ['port status'])) {
    return const [];
  }

  return const [];
}

bool _containsAny(String value, List<String> candidates) {
  return candidates.any(value.contains);
}

String _normalize(String value) {
  return value.replaceAll('_', ' ').replaceAll('-', ' ').trim().toLowerCase();
}
