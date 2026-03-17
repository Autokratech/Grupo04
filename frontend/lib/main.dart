import 'package:flutter/widgets.dart';

Future<void> main() async {
  // Initialize the Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Awaits for dependencies configuration
  await setupDependencies();

  // Runs the app
  runApp(App());
}
