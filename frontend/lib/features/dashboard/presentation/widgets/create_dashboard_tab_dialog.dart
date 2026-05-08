import 'package:flutter/material.dart';

class CreateDashboardTabDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? initialName;

  const CreateDashboardTabDialog({
    super.key,
    this.title = 'Nuevo dashboard',
    this.submitLabel = 'Crear',
    this.initialName,
  });

  @override
  State<CreateDashboardTabDialog> createState() =>
      _CreateDashboardTabDialogState();
}

class _CreateDashboardTabDialogState extends State<CreateDashboardTabDialog> {
  late final TextEditingController _nameController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Introduce un nombre';
      });

      return;
    }

    final initialName = widget.initialName?.trim();

    if (initialName != null && name == initialName) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.title, textAlign: TextAlign.center),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Nombre',
          errorText: _errorMessage,
        ),
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
        FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
      ],
    );
  }
}
