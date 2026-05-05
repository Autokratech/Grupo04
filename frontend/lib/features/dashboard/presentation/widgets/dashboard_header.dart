import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showText;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showText)
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
        )
        else
          const Spacer(),
        ?trailing,
      ],
    );
  }
}