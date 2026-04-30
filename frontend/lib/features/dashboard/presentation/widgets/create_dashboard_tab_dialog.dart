import 'package:flutter/material.dart';

class CreateDashboardTabDialog extends StatefulWidget {
  const CreateDashboardTabDialog({super.key});

  @override
  State<CreateDashboardTabDialog> createState() =>
      _CreateDashboardTabDialogState();
}

class _CreateDashboardTabDialogState extends State<CreateDashboardTabDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Introduce un nombre";
      });

      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Nuevo dashboard", textAlign: TextAlign.center),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(errorText: _errorMessage),
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_errorMessage == null) return;

          setState(() {
            _errorMessage = null;
          });
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text("Crear")),
      ],
    );
  }
}
