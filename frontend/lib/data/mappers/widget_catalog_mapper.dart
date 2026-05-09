import 'package:frontend/data/models/dto/dashboard_dtos/widget_catalog_item_dto.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/domain/models/widget_type.dart';

class WidgetCatalogMapper {
  const WidgetCatalogMapper._();

  static List<WidgetCatalogItem> toDomainList(List<WidgetCatalogItemDto> dtos) {
    return dtos
        .map(toDomain)
        .where((item) => item.id.trim().isNotEmpty)
        .toList();
  }

  static WidgetCatalogItem toDomain(WidgetCatalogItemDto dto) {
    return WidgetCatalogItem(
      id: dto.id,
      title: _resolveTitle(dto),
      type: _mapType(dto.type),
      description: dto.description ?? 'Widget disponible para añadir.',
      metadataLabel: _resolveMetadataLabel(dto),
    );
  }

  static String _resolveTitle(WidgetCatalogItemDto dto) {
    final name = dto.name?.trim();

    if (name != null && name.isNotEmpty) {
      return _formatLabel(name);
    }

    final type = dto.type?.trim();

    if (type != null && type.isNotEmpty) {
      return _formatLabel(type);
    }

    return 'Widget';
  }

  static String _resolveMetadataLabel(WidgetCatalogItemDto dto) {
    final function = dto.function?.trim();

    if (function == null || function.isEmpty) {
      return 'Función no especificada';
    }

    return 'Función: ${_formatLabel(function)}';
  }

  static WidgetType _mapType(String? rawType) {
    switch (rawType?.toUpperCase()) {
      case 'AREA_CHART':
      case 'PIE_CHART':
      case 'LINE_CHART':
        return WidgetType.chart;

      case 'TEXT_LIST':
      case 'LIST_RESOURCES':
        return WidgetType.list;

      case 'GAUGE':
      case 'PROGRESS_BAR':
        return WidgetType.metric;

      case 'PIPELINE':
        return WidgetType.pipeline;

      case 'MERGE_REQUEST':
      case 'ISSUE':
        return WidgetType.issue;

      default:
        return WidgetType.status;
    }
  }

  static String _formatLabel(String value) {
    final normalized = value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .toLowerCase();

    if (normalized.isEmpty) {
      return value;
    }

    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}
