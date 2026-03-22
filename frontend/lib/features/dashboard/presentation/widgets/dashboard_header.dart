import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onLogoutPressed;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        TextButton(
            onPressed: onLogoutPressed,
            child: const Text('Cerrar sesión')
        ),
      ],
    );
  }
}
