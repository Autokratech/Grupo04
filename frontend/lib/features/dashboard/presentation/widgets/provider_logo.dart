import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/features/dashboard/presentation/utils/provider_assets.dart';

class ProviderLogo extends StatelessWidget {
  final String? provider;
  final double size;

  const ProviderLogo({
    super.key,
    required this.provider,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = ProviderAssets.fromProvider(provider);

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}