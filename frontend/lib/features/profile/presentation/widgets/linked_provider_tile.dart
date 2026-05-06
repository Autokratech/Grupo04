import 'package:flutter/material.dart';
import 'package:frontend/domain/models/linked_provider_status.dart';

class LinkedProviderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final LinkedProviderStatus status;
  final String? actionLabel;
  final VoidCallback? onAction;

  const LinkedProviderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusLabel = _statusLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBackgroundColor(colorScheme),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: _statusColor(colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel() {
    return switch (status) {
      LinkedProviderStatus.connected => 'Conectado',
      LinkedProviderStatus.disconnected => 'No conectado',
      LinkedProviderStatus.unavailable => 'No disponible',
      LinkedProviderStatus.error => 'Error',
    };
  }

  Color _statusColor(ColorScheme colorScheme) {
    return switch (status) {
      LinkedProviderStatus.connected => colorScheme.onPrimaryContainer,
      LinkedProviderStatus.disconnected => colorScheme.onSecondaryContainer,
      LinkedProviderStatus.unavailable => colorScheme.onTertiaryContainer,
      LinkedProviderStatus.error => colorScheme.onErrorContainer,
    };
  }

  Color _statusBackgroundColor(ColorScheme colorScheme) {
    return switch (status) {
      LinkedProviderStatus.connected => colorScheme.primaryContainer,
      LinkedProviderStatus.disconnected => colorScheme.secondaryContainer,
      LinkedProviderStatus.unavailable => colorScheme.tertiaryContainer,
      LinkedProviderStatus.error => colorScheme.errorContainer,
    };
  }
}