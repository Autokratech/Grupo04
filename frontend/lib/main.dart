import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'app/di/sevice_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const App());
}
