import 'package:flutter/material.dart';
import 'package:frontend/app/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _runStartupFlow();
  }

  void _runStartupFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Autokratech",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
