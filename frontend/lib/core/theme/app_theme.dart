import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    textTheme: const TextTheme(
      headlineSmall: AppTextStyles.headline,
      titleLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySecondary,
      labelLarge: AppTextStyles.label,
    ),
  );
}
