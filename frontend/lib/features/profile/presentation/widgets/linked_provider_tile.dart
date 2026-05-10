import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(icon, size: 22, color: colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildStatusBadge(context),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _statusBackgroundColor(colorScheme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel(),
        style: textTheme.labelSmall?.copyWith(
          color: _statusColor(colorScheme),
          fontWeight: FontWeight.w600,
        ),
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
