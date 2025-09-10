import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MediCycleApp()));
}

class MediCycleApp extends StatelessWidget {
  const MediCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '약드셔유',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
}
