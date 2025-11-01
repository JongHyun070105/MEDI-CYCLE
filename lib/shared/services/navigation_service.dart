import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static void showSnack(
    String message, {
    Color color = const Color(0xFF333333),
  }) {
    final ctx = context;
    if (ctx == null) return;
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  static void forceLogoutToSplash({String? message}) {
    final ctx = context;
    if (ctx == null) return;
    if (message != null && message.isNotEmpty) {
      showSnack(message, color: Colors.red);
    }
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }
}
