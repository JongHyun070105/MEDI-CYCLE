import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 사용자 정보 카드
            Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // 프로필 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // 사용자 이름
                  Text(
                    authState.user?.name ?? '사용자',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSizes.xs),

                  // 이메일
                  Text(
                    authState.user?.email ?? 'user@example.com',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // 설정 메뉴
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // 회원정보 수정
                  _buildSettingsItem(
                    icon: Icons.edit_outlined,
                    title: '회원정보 수정',
                    subtitle: '이름, 이메일, 프로필 정보를 수정합니다',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDivider(),

                  // 알림 설정
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    subtitle: '복용 알림, 약물 만료 알림 등을 설정합니다',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 설정 기능은 준비 중입니다.')),
                      );
                    },
                  ),

                  _buildDivider(),

                  // 개인정보 처리방침
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 처리방침',
                    subtitle: '개인정보 수집 및 이용에 대한 안내',
                    onTap: () {
                      _showPrivacyPolicyDialog(context);
                    },
                  ),

                  _buildDivider(),

                  // 이용약관
                  _buildSettingsItem(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    subtitle: '서비스 이용약관 및 정책',
                    onTap: () {
                      _showTermsDialog(context);
                    },
                  ),

                  _buildDivider(),

                  // 앱 정보
                  _buildSettingsItem(
                    icon: Icons.info_outlined,
                    title: '앱 정보',
                    subtitle: '버전 1.0.0',
                    onTap: () {
                      _showAppInfoDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // 로그아웃 버튼
            CustomButton(
              text: '로그아웃',
              onPressed: () => _showLogoutDialog(context, ref),
              isOutlined: true,
              backgroundColor: AppColors.error,
              textColor: AppColors.error,
            ),

            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSizes.iconSm,
              ),
            ),

            const SizedBox(width: AppSizes.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      color: AppColors.border,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // 로그아웃 처리
              final authController = ref.read(authControllerProvider.notifier);
              await authController.logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('로그아웃', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '여기에 개인정보 처리방침 내용이 들어갑니다.\n\n'
            '1. 개인정보의 수집 및 이용 목적\n'
            '2. 수집하는 개인정보의 항목\n'
            '3. 개인정보의 보유 및 이용 기간\n'
            '4. 개인정보의 제3자 제공\n'
            '5. 개인정보 처리의 위탁\n'
            '6. 정보주체의 권리\n'
            '7. 개인정보 보호책임자\n\n'
            '자세한 내용은 앱 내 설정에서 확인하실 수 있습니다.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '여기에 이용약관 내용이 들어갑니다.\n\n'
            '제1조 (목적)\n'
            '제2조 (정의)\n'
            '제3조 (약관의 효력 및 변경)\n'
            '제4조 (서비스의 제공)\n'
            '제5조 (서비스의 중단)\n'
            '제6조 (회원가입)\n'
            '제7조 (회원 탈퇴 및 자격 상실)\n'
            '제8조 (회원에 대한 통지)\n'
            '제9조 (개인정보보호)\n'
            '제10조 (회사의 의무)\n\n'
            '자세한 내용은 앱 내 설정에서 확인하실 수 있습니다.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('약드셔유', style: AppTextStyles.h6),
            const SizedBox(height: AppSizes.sm),
            const Text('버전: 1.0.0'),
            const SizedBox(height: AppSizes.sm),
            const Text('빌드: 1'),
            const SizedBox(height: AppSizes.sm),
            const Text('개발자: 약드셔유 Team'),
            const SizedBox(height: AppSizes.sm),
            const Text(
              '안전한 의약품 순환 관리 서비스\n환경오염 방지를 위한 통합 플랫폼',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
