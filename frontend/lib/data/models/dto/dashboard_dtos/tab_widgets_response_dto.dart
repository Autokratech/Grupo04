import 'package:frontend/data/models/dto/dashboard_dtos/tab_widget_data_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widget_dto.dart';

class TabWidgetsResponseDto {
  final List<TabWidgetDto> tabWidgets;
  final List<TabWidgetDataDto> tabWidgetsData;

  const TabWidgetsResponseDto({
    required this.tabWidgets,
    required this.tabWidgetsData,
  });

  factory TabWidgetsResponseDto.fromMap(Map<String, dynamic> map) {
    return TabWidgetsResponseDto(
      tabWidgets: _parseList(
        map['tab_widgets'],
        TabWidgetDto.fromMap,
      ),
      tabWidgetsData: _parseList(
        map['tab_widgets_data'],
        TabWidgetDataDto.fromMap,
      ),
    );
  }
}

List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic> map) fromMap,
    ) {
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map((item) => fromMap(Map<String, dynamic>.from(item)))
      .toList();
}
