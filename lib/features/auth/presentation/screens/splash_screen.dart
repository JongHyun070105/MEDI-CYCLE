import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/api_client.dart';
import '../controllers/splash_controller.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import '../../../medication/presentation/screens/medication_home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
  }

  void _startSplashSequence() async {
    // 로고 애니메이션 시작
    _logoController.forward();

    // 500ms 후 텍스트 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // 2초 후 네트워크 확인 및 다음 화면으로 이동
    await Future.delayed(const Duration(milliseconds: 2000));
    _checkNetworkAndNavigate();
  }

  void _checkNetworkAndNavigate() async {
    final splashController = ref.read(splashControllerProvider.notifier);
    await splashController.checkNetworkConnection();

    if (mounted) {
      // 저장된 토큰을 메모리로 동기화 후 자동 로그인 시도
      final autoLoginEnabled = await ApiClient().getAutoLoginEnabled();
      await apiService.syncTokenFromStorage();
      final hasToken = apiService.isLoggedIn && autoLoginEnabled;
      if (hasToken) {
        try {
          final authController = ref.read(authControllerProvider.notifier);
          final expectedUserId = await ApiClient().getStoredUserId();
          final expectedEmail = await ApiClient().getStoredUserEmail();
          final success = await authController.loadUserProfile(
            expectedUserId: expectedUserId,
            expectedEmail: expectedEmail,
          );
          if (!success) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
            return;
          }
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MedicationHomeScreen(),
            ),
          );
        } catch (_) {
          // 토큰이 유효하지 않으면 로그인 화면으로
          await ref.read(authControllerProvider.notifier).logout();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 애니메이션
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.xl),

                // 앱 이름 애니메이션
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            Text(
                              '약드셔유',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Jua',
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              '안전한 의약품 순환 관리',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'Jua',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (splashState.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSizes.xxl),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
