import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/mappers/dashboard_mapper.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tabs/dashboard_tab_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tabs/dashboard_tabs_response_dto.dart';

void main() {
  group('DashboardMapper.toDomain', () {
    test('convierte theme y language vacíos en null', () {
      final dto = DashboardDto(
        id: 'dashboard-1',
        theme: '   ',
        language: '',
      );

      final dashboard = DashboardMapper.toDomain(dto);

      expect(dashboard.id, 'dashboard-1');
      expect(dashboard.theme, isNull);
      expect(dashboard.language, isNull);
    });

    test('mantiene theme y language cuando tienen contenido', () {
      final dto = DashboardDto(
        id: 'dashboard-1',
        theme: 'dark',
        language: 'es',
      );

      final dashboard = DashboardMapper.toDomain(dto);

      expect(dashboard.id, 'dashboard-1');
      expect(dashboard.theme, 'dark');
      expect(dashboard.language, 'es');
    });
  });

  group('DashboardMapper.tabToDomain', () {
    test('convierte el índice del backend a posición interna', () {
      final dto = DashboardTabDto(
        id: 'tab-1',
        index: 3,
        name: 'Widgets',
      );

      final tab = DashboardMapper.tabToDomain(dto);

      expect(tab.id, 'tab-1');
      expect(tab.name, 'Widgets');
      expect(tab.position, 2);
    });

    test('usa Dashboard como nombre por defecto si la tab no tiene nombre', () {
      final dto = DashboardTabDto(
        id: 'tab-1',
        index: 1,
        name: '   ',
      );

      final tab = DashboardMapper.tabToDomain(dto);

      expect(tab.name, 'Dashboard');
      expect(tab.position, 0);
    });
  });

  group('DashboardMapper.tabsToDomain', () {
    test('ordena las tabs e ignora las que no tienen id', () {
      final dto = DashboardTabsResponseDto(
        tabs: [
          DashboardTabDto(id: 'tab-3', index: 3, name: 'Tercera'),
          DashboardTabDto(id: '', index: 1, name: 'Inválida'),
          DashboardTabDto(id: 'tab-1', index: 1, name: 'Primera'),
          DashboardTabDto(id: 'tab-2', index: 2, name: 'Segunda'),
        ],
      );

      final tabs = DashboardMapper.tabsToDomain(dto);

      expect(tabs.length, 3);

      expect(tabs[0].id, 'tab-1');
      expect(tabs[0].position, 0);

      expect(tabs[1].id, 'tab-2');
      expect(tabs[1].position, 1);

      expect(tabs[2].id, 'tab-3');
      expect(tabs[2].position, 2);
    });
  });
}