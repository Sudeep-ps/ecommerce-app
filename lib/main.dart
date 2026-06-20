import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/product_list/presentation/screens/product_list_screen.dart';
import 'providers/core_providers.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  // Required before calling any async platform-channel APIs (like
  // SharedPreferences) prior to runApp().
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Resolve the "real" SharedPreferences instance once at startup and
        // inject it, so every other provider that depends on it (cart,
        // theme) can stay synchronous instead of needing its own
        // FutureProvider/loading state.
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const ProductListScreen(),
    );
  }
}
