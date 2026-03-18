import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'app/di/sevice_locator.dart';

Future<void> main() async {
  // Initialize the Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Awaits for dependencies configuration
  await setupDependencies();

  // Runs the app
  runApp(const App());
}
