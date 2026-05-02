import 'package:flutter/material.dart';

class LinkedProviderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String statusLabel;
  final bool connected;

  const LinkedProviderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.statusLabel,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: statusLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              connected ? 'Conectado' : 'No conectado',
              style: textTheme.bodySmall?.copyWith(
                color: connected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}