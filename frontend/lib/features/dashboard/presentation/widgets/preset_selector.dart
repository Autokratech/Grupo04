import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';

class PresetSelector extends StatelessWidget {
  final List<DashboardPreset> presets;
  final DashboardPreset selectedPreset;
  final ValueChanged<DashboardPreset> onPresetChanged;

  const PresetSelector({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DashboardPreset>(
      initialValue: selectedPreset,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Perfiles',
        border: OutlineInputBorder(),
      ),
      items: presets
          .map(
            (preset) => DropdownMenuItem<DashboardPreset>(
              value: preset,
              child: Text(preset.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onPresetChanged(value);
      },
    );
  }
}
