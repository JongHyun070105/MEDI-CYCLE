import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'shared/services/api_client.dart';
import 'shared/services/navigation_service.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ApiClient 초기화
  final apiClient = ApiClient();
  await apiClient.initializePrefs();

  // 알림 서비스 초기화
  await notificationService.initialize();

  runApp(const ProviderScope(child: YakDrugYouApp()));
}

class YakDrugYouApp extends StatelessWidget {
  const YakDrugYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '약드셔유',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}
