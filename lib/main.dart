import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/src/core/configs/router.dart';
import 'package:gre_vocabulary/src/core/configs/theme.dart';
import 'package:gre_vocabulary/src/services_initializer.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final container = ProviderContainer();
  await container.read(initializer.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GRE Vocabulary',
      // TODO: Change theme
      theme: AppThemes.getTheme(),
      darkTheme: AppThemes.getTheme(themeMode: ThemeMode.dark),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
