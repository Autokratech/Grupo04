import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';

class DashboardCard extends StatelessWidget {
  final DashboardWidgetItem item;

  const DashboardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text('${item.type.name} · ${item.status.name}'),
        trailing: Text(item.primaryValue),
      ),
    );
  }
}
