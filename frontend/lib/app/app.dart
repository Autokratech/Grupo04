import 'package:flutter/material.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';

// Initializes the router and the theme
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.theme,
    );
  }
}
