import 'package:frontend/domain/models/widget_add_option.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';

class AddWidgetDialogResult {
  final WidgetCatalogItem item;
  final WidgetAddOption option;

  const AddWidgetDialogResult({
    required this.item,
    required this.option,
  });
}