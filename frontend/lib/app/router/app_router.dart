import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'package:frontend/features/auth/presentation/screens/auth_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(),
          transitionDuration: const Duration(milliseconds: 180),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 180),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
}
