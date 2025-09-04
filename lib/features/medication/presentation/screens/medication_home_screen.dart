import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/medication_stats.dart';
import 'medication_registration_screen.dart';
import 'disposal_screen.dart';
import 'medication_box_screen.dart';
import 'ai_feedback_screen.dart';
import 'chatbot_screen.dart';

class MedicationHomeScreen extends ConsumerStatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  ConsumerState<MedicationHomeScreen> createState() =>
      _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends ConsumerState<MedicationHomeScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: _currentIndex == 2
          ? AppBar(
              title: const Text(''),
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: 알림 설정 화면으로 이동
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    // TODO: 설정 화면으로 이동
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DisposalTab(),
          _MedicationTab(),
          _HomeTab(),
          _PharmacyTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          enableFeedback: false,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              activeIcon: Icon(Icons.delete),
              label: '폐의약품',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: '약 등록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: '약 상자',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'AI 피드백',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        splashColor: Colors.transparent,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘의 약물 통계
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Text(
                '오늘의 통계',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const MedicationStats(),

          const SizedBox(height: AppSizes.lg),

          // 오늘의 복약 현황
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '오늘의 복약 현황',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // 투두리스트 스타일의 복약 현황
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              children: [
                _MedicationItem(name: '혈압약', time: '오전 08:00', isTaken: true),
                _buildDivider(),
                _MedicationItem(name: '당뇨약', time: '오후 12:10', isTaken: true),
                _buildDivider(),
                _MedicationItem(name: '소화제', time: '오후 05:30', isTaken: true),
                _buildDivider(),
                _MedicationItem(name: '수면제', time: '오후 10:50', isTaken: false),
              ],
            ),
          ),
          // FAB 버튼이 가리는 것을 방지하기 위한 하단 패딩
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class _MedicationTab extends StatelessWidget {
  const _MedicationTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('약 등록'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 임시 저장
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.md),

            // 메인 아이콘과 제목
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Icon(Icons.medication, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.md),

            Text(
              '약 등록',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              '새로운 약을 등록하여\n복용 관리를 시작해보세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),

            // 기능 설명 카드들
            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: '사진으로 등록',
              description: '처방전이나 약봉지를 촬영하여\n자동으로 약 정보를 입력합니다',
            ),
            const SizedBox(height: AppSizes.md),

            _buildFeatureCard(
              icon: Icons.edit,
              title: '직접 입력',
              description: '약 이름, 복용 시간, 기간 등을\n직접 입력하여 등록합니다',
            ),
            const SizedBox(height: AppSizes.lg),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MedicationRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('약 등록 시작하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisposalTab extends StatelessWidget {
  const _DisposalTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('폐의약품 처리'),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.location_on, color: AppColors.textPrimary),
              onPressed: () {
                // TODO: 현재 위치로 이동
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '가까운 수거함'),
                Tab(text: '지도에서 보기'),
                Tab(text: '방문 수거 신청'),
              ],
            ),
          ),
        ),
        body: const DisposalScreen(),
      ),
    );
  }
}

class _PharmacyTab extends StatelessWidget {
  const _PharmacyTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('약 상자 상태'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 상태 새로고침
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 약 상자 설정
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: const MedicationBoxScreen(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('AI 피드백'),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textPrimary),
              onPressed: () {
                // TODO: 리포트 공유
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: const Icon(Icons.download, color: AppColors.textPrimary),
              onPressed: () {
                // TODO: 리포트 다운로드
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '월별 복용률'),
                Tab(text: '평일/주말'),
              ],
            ),
          ),
        ),
        body: const AiFeedbackScreen(),
      ),
    );
  }
}

// 투두리스트 스타일의 약물 항목 위젯
class _MedicationItem extends StatefulWidget {
  final String name;
  final String time;
  final bool isTaken;

  const _MedicationItem({
    required this.name,
    required this.time,
    required this.isTaken,
  });

  @override
  State<_MedicationItem> createState() => _MedicationItemState();
}

class _MedicationItemState extends State<_MedicationItem> {
  late bool _isTaken;

  @override
  void initState() {
    super.initState();
    _isTaken = widget.isTaken;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _isTaken
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: _isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  widget.time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isTaken = !_isTaken;
              });

              // 복용 완료/취소 피드백
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isTaken ? '${widget.name} 복용 완료!' : '${widget.name} 복용 취소',
                  ),
                  backgroundColor: _isTaken
                      ? AppColors.success
                      : AppColors.warning,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isTaken ? AppColors.primary : Colors.white,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// 구분선 위젯
Widget _buildDivider() {
  return Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
    color: AppColors.border,
  );
}
