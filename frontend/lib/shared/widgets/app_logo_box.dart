import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/app_colors.dart';

class AppLogoBox extends StatelessWidget {
  static const String _assetPath = 'assets/icons/logo/a.svg';

  final double size;
  final double logoSize;
  final double borderRadius;

  const AppLogoBox({
    super.key,
    this.size = 46,
    this.logoSize = 30,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all((size - logoSize) / 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: SvgPicture.asset(
        _assetPath,
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}