import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool showText;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        if (showText) ...[
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else
          const Spacer(),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8),
            child: trailing!,
          ),
      ],
    );
  }
}
