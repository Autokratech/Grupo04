import 'package:flutter/material.dart';

class DeleteDashboardTabDialog extends StatelessWidget {
  final String dashboardName;

  const DeleteDashboardTabDialog({super.key, required this.dashboardName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Eliminar dashboard', textAlign: TextAlign.center),
      content: Text(
        '¿Seguro que quieres eliminar el dashboard "$dashboardName"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
