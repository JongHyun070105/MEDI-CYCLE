import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';

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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsScreen(),
                        ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('정말 로그아웃 하시겠습니까?'),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: SingleChildScrollView(
          child: Text(
            '약드셔유(MediCycle)는 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.\n\n'
            '1. 개인정보의 수집 및 이용 목적\n'
            '약드셔유는 다음의 목적을 위하여 개인정보를 처리합니다:\n'
            '• 의약품 복용 관리 및 알림 서비스 제공\n'
            '• 사용자 맞춤형 복약 관리 및 피드백 제공\n'
            '• 약물 만료 알림 및 순환 관리 서비스 제공\n'
            '• 블루투스 약상자 연결 서비스 제공\n'
            '• AI 기반 복약 상담 및 인사이트 제공\n'
            '• 서비스 이용에 따른 본인 식별·인증\n'
            '• 회원 가입 의사 확인, 가입 및 가입 횟수 제한\n'
            '• 서비스 부정 이용 방지 및 각종 고지·통지\n\n'
            '2. 수집하는 개인정보의 항목\n'
            '약드셔유는 다음의 개인정보 항목을 처리하고 있습니다:\n'
            '• 필수 항목: 이메일, 비밀번호, 이름\n'
            '• 선택 항목: 나이, 주소, 성별, 자동 로그인 설정\n'
            '• 서비스 이용 과정에서 자동으로 생성되어 수집되는 정보: 접속 IP 주소, 쿠키, 접속 로그, 기기 정보, 약물 정보, 복용 기록\n'
            '• 블루투스 기기 정보: 약상자 연결 정보\n\n'
            '3. 개인정보의 보유 및 이용 기간\n'
            '① 약드셔유는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n'
            '② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다:\n'
            '• 회원 가입 및 관리: 회원 탈퇴 시까지 (단, 관련 법령 및 회사 정책에 따라 보관이 필요한 경우 해당 기간 동안 보관)\n'
            '• 의약품 복용 기록: 서비스 이용 종료 후 3년\n'
            '• 약물 정보: 서비스 이용 종료 시까지\n'
            '• 로그인 기록: 3개월 (통신비밀보호법)\n\n'
            '4. 개인정보의 제3자 제공\n'
            '약드셔유는 정보주체의 개인정보를 제1조(개인정보의 수집 및 이용 목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 「개인정보 보호법」 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.\n'
            '• 제공받는 자: Google (Gemini API 서비스 제공)\n'
            '• 제공 항목: 복약 기록 데이터 (익명화 처리)\n'
            '• 제공 목적: AI 기반 복약 상담 서비스 제공\n'
            '• 보유 및 이용 기간: 서비스 이용 종료 시까지\n\n'
            '5. 개인정보 처리의 위탁\n'
            '약드셔유는 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다:\n'
            '• 위탁받는 자: Google Cloud Platform\n'
            '• 위탁 업무의 내용: 서버 인프라 운영 및 데이터 보관\n'
            '• 위탁 기간: 서비스 제공 기간 동안\n\n'
            '6. 정보주체의 권리·의무 및 그 행사방법\n'
            '① 정보주체는 약드셔유에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다:\n'
            '• 개인정보 처리정지 요구권\n'
            '• 개인정보 열람 요구권\n'
            '• 개인정보 정정·삭제 요구권\n'
            '• 개인정보 처리정지 요구권\n'
            '② 제1항에 따른 권리 행사는 약드셔유에 대해 「개인정보 보호법」 시행령 제41조 제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 약드셔유는 이에 대해 지체 없이 조치하겠습니다.\n\n'
            '7. 개인정보 보호책임자\n'
            '약드셔유는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다:\n'
            '• 개인정보 보호책임자: 약드셔유 팀\n'
            '• 연락처: support@yarkdrug.app\n\n'
            '8. 개인정보의 안전성 확보조치\n'
            '약드셔유는 「개인정보 보호법」 제29조에 따라 다음과 같이 안전성 확보에 필요한 기술적/관리적 및 물리적 조치를 하고 있습니다:\n'
            '• 개인정보 암호화: 비밀번호는 암호화하여 저장\n'
            '• 접근 제한: 개인정보 처리 직원에 대한 접근 권한 관리\n'
            '• 보안 프로그램 설치: 해킹 및 바이러스 방지\n'
            '• 개인정보 접근 로그 관리: 접속 기록 보관\n\n'
            '9. 개인정보 처리방침 변경\n'
            '이 개인정보 처리방침은 2025년 11월 1일부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.\n\n'
            '본 방침은 2025년 11월 1일부터 시행됩니다.',
            style: AppTextStyles.bodySmall,
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
        content: SingleChildScrollView(
          child: Text(
            '제1조 (목적)\n'
            '본 약관은 약드셔유(MediCycle, 이하 "회사"라 함)가 제공하는 의약품 순환 관리 서비스(이하 "서비스"라 함)의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.\n\n'
            '제2조 (정의)\n'
            '① "서비스"란 회사가 제공하는 의약품 복용 관리, 약물 만료 알림, 블루투스 약상자 연결, AI 기반 복약 상담 등의 서비스를 의미합니다.\n'
            '② "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 의미합니다.\n'
            '③ "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며, 회사가 제공하는 서비스를 계속적으로 이용할 수 있는 자를 의미합니다.\n'
            '④ "비회원"이란 회원에 가입하지 않고 회사가 제공하는 서비스를 이용하는 자를 의미합니다.\n\n'
            '제3조 (약관의 효력 및 변경)\n'
            '① 본 약관은 서비스를 이용하고자 하는 모든 이용자에 대하여 그 효력을 발생합니다.\n'
            '② 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.\n'
            '③ 약관이 변경되는 경우 회사는 변경 사항을 시행일자 7일 전부터 공지사항을 통해 공지합니다.\n'
            '④ 이용자는 변경된 약관에 대해 거부할 권리가 있으며, 변경된 약관에 거부하는 경우 서비스 이용이 제한될 수 있습니다.\n\n'
            '제4조 (서비스의 제공)\n'
            '① 회사는 다음과 같은 서비스를 제공합니다:\n'
            '• 의약품 복용 관리 및 알림 서비스\n'
            '• 약물 만료 알림 서비스\n'
            '• 블루투스 약상자 연결 서비스\n'
            '• AI 기반 복약 상담 및 인사이트 제공\n'
            '• 복약 기록 관리 및 리포트 생성\n'
            '• 기타 회사가 추가 개발하거나 제휴 계약 등을 통해 이용자에게 제공하는 일체의 서비스\n'
            '② 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다. 다만, 회사는 서비스의 안정성을 위해 정기 점검, 시스템 업그레이드 등의 작업이 필요한 경우 서비스 제공을 일시 중단할 수 있습니다.\n\n'
            '제5조 (서비스의 중단)\n'
            '① 회사는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.\n'
            '② 회사는 제1항의 사유로 서비스의 제공이 일시적으로 중단됨으로 인하여 이용자 또는 제3자가 입은 손해에 대하여 배상합니다. 단, 회사가 고의 또는 과실이 없음을 입증하는 경우에는 그러하지 아니합니다.\n'
            '③ 사업종목의 전환, 사업의 포기, 업체 간의 통합 등의 이유로 서비스를 제공할 수 없게 되는 경우에는 회사는 제8조에 정한 방법으로 이용자에게 통지하고 당초 회사에서 제시한 조건에 따라 이용자에게 보상합니다.\n\n'
            '제6조 (회원가입)\n'
            '① 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 본 약관에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.\n'
            '② 회사는 제1항과 같이 회원가입을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다:\n'
            '• 가입신청자가 본 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우\n'
            '• 등록 내용에 허위, 기재누락, 오기가 있는 경우\n'
            '• 기타 회원으로 등록하는 것이 회사의 기술상 현저히 지장이 있다고 판단되는 경우\n'
            '③ 회원가입 계약의 성립 시기는 회사의 승낙이 회원에게 도달한 시점으로 합니다.\n'
            '④ 회원은 개인정보관리화면을 통하여 언제든지 본인의 개인정보를 열람하고 수정할 수 있습니다. 다만, 서비스 관리를 위해 필요한 실명, 아이디 등은 수정이 불가능합니다.\n\n'
            '제7조 (회원 탈퇴 및 자격 상실)\n'
            '① 회원은 회사에 언제든지 탈퇴를 요청할 수 있으며 회사는 즉시 회원탈퇴를 처리합니다.\n'
            '② 회원이 다음 각 호의 사유에 해당하는 경우, 회사는 회원자격을 제한 및 정지시킬 수 있습니다:\n'
            '• 가입 신청 시에 허위 내용을 등록한 경우\n'
            '• 다른 사람의 서비스 이용을 방해하거나 그 정보를 도용하는 등 전자상거래 질서를 위협하는 경우\n'
            '• 서비스를 이용하여 법령 또는 본 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우\n'
            '③ 회사가 회원 자격을 제한·정지 시킨 후, 동일한 행위가 2회 이상 반복되거나 30일 이내에 그 사유가 시정되지 아니하는 경우 회사는 회원자격을 상실시킬 수 있습니다.\n\n'
            '제8조 (회원에 대한 통지)\n'
            '① 회사가 회원에 대한 통지를 하는 경우, 회원이 회사에 제출한 전자우편 주소로 할 수 있습니다.\n'
            '② 회사는 불특정다수 회원에 대한 통지의 경우 1주일 이상 서비스 게시판에 게시함으로서 개별 통지에 갈음할 수 있습니다.\n\n'
            '제9조 (개인정보보호)\n'
            '① 회사는 이용자의 개인정보 수집 시 서비스 제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집합니다.\n'
            '② 회사는 회원가입 시 구매계약이행에 필요한 정보를 미리 수집하지 않습니다. 다만, 관련 법령상 의무이행을 위하여 필요한 경우에는 예외로 합니다.\n'
            '③ 회사는 이용자의 개인정보를 수집·이용하는 때에는 당해 이용자에게 그 목적을 고지하고 동의를 받습니다.\n'
            '④ 회사는 수집된 개인정보를 목적 외의 용도로 이용할 수 없으며, 새로운 이용 목적이 발생한 경우 또는 제3자에게 제공하는 경우에는 이용·제공 단계에서 당해 이용자에게 그 목적을 고지하고 동의를 받습니다.\n'
            '⑤ 회사는 「개인정보 보호법」에 따라 개인정보 처리방침을 수립하고 이를 공개합니다.\n\n'
            '제10조 (회사의 의무)\n'
            '① 회사는 법령과 본 약관이 금지하거나 공서양속에 반하는 행위를 하지 않으며, 본 약관이 정하는 바에 따라 지속적이고, 안정적으로 서비스를 제공하는데 최선을 다하여야 합니다.\n'
            '② 회사는 이용자가 안전하게 서비스를 이용할 수 있도록 개인정보(신용정보 포함) 보호를 위해 보안시스템을 갖추어야 하며 개인정보처리방침을 공시하고 준수합니다.\n'
            '③ 회사는 서비스 이용과 관련하여 이용자로부터 제기된 의견이나 불만이 정당하다고 인정할 경우에는 이를 처리하여야 합니다.\n\n'
            '제11조 (이용자의 의무)\n'
            '① 이용자는 다음 행위를 하여서는 안 됩니다:\n'
            '• 신청 또는 변경 시 허위 내용의 등록\n'
            '• 타인의 정보 도용\n'
            '• 회사가 게시한 정보의 변경\n'
            '• 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시\n'
            '• 회사와 기타 제3자의 저작권 등 지적재산권에 대한 침해\n'
            '• 회사 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위\n'
            '• 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시하는 행위\n\n'
            '제12조 (서비스 이용의 제한)\n'
            '① 회사는 이용자가 본 약관의 의무를 위반하거나 서비스의 정상적인 운영을 방해한 경우, 경고, 일시정지, 영구이용정지 등으로 서비스 이용을 단계적으로 제한할 수 있습니다.\n'
            '② 회사는 전항에도 불구하고, 주민등록법을 위반한 명의도용 및 결제도용, 전화번호 도용, 본인확인 기관의 본인확인 및 개인정보보호법 위반 등 위반 행위가 확인된 경우 즉시 영구이용정지를 할 수 있습니다.\n\n'
            '제13조 (손해배상)\n'
            '① 회사는 무료로 제공되는 서비스와 관련하여 회원에게 어떠한 손해가 발생하더라도 동 손해가 회사의 중대한 과실에 의한 경우를 제외하고 이에 대하여 책임을 부담하지 아니합니다.\n'
            '② 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n\n'
            '제14조 (준거법 및 관할법원)\n'
            '① 회사와 이용자 간에 발생한 전자상거래 분쟁에 관한 소송은 제소 당시의 이용자의 주소에 의하고, 주소가 없는 경우에는 거소를 관할하는 지방법원의 전속관할로 합니다.\n'
            '② 회사와 이용자 간에 발생한 전자상거래 분쟁에 관한 소송은 대한민국 법을 준거법으로 합니다.\n\n'
            '본 약관은 2025년 11월 1일부터 시행됩니다.',
            style: AppTextStyles.bodySmall,
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
