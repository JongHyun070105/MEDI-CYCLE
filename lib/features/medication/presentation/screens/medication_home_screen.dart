import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/medication_stats.dart';
import '../widgets/pillbox_stats.dart';
import 'medication_registration_screen.dart';
import 'disposal_screen.dart';
import 'medication_box_screen.dart';
import 'ai_feedback_screen.dart';
import 'chatbot_screen.dart';
import '../../../auth/presentation/screens/settings_screen.dart';
import '../../../../shared/services/api_client.dart';

class MedicationHomeScreen extends ConsumerStatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  ConsumerState<MedicationHomeScreen> createState() =>
      _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends ConsumerState<MedicationHomeScreen> {
  int _currentIndex = 2;
  final GlobalKey<_HomeTabState> _homeTabKey = GlobalKey<_HomeTabState>();
  final GlobalKey<_MedicationTabState> _medicationTabKey =
      GlobalKey<_MedicationTabState>();

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
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _DisposalTab(),
          _MedicationTab(key: _medicationTabKey),
          _HomeTab(key: _homeTabKey),
          const _PharmacyTab(),
          const _ProfileTab(),
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
        heroTag: "main_fab",
        onPressed: () async {
          if (_currentIndex == 1) {
            // 약 등록 탭일 때는 약 등록 화면으로 이동
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicationRegistrationScreen(
                  onMedicationAdded: (medication) {
                    // 약이 추가될 때마다 리스트에 추가
                    _medicationTabKey.currentState?.addMedication(medication);
                    _homeTabKey.currentState?.refreshAll();
                  },
                ),
              ),
            );
            if (result != null && result is Map<String, dynamic>) {
              _medicationTabKey.currentState?.addMedication(result);
              _homeTabKey.currentState?.refreshAll();
            }
          } else {
            // 다른 탭일 때는 챗봇으로 이동
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        splashColor: Colors.transparent,
        child: Icon(
          _currentIndex == 1 ? Icons.add : Icons.chat,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({super.key});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final GlobalKey<MedicationStatsState> _statsKey =
      GlobalKey<MedicationStatsState>();
  final GlobalKey<_TodayIntakeChecklistState> _checklistKey =
      GlobalKey<_TodayIntakeChecklistState>();

  void refreshAll() {
    refreshStats();
    refreshChecklist();
  }

  void refreshStats() {
    _statsKey.currentState?.refreshStatistics();
  }

  void refreshChecklist() {
    _checklistKey.currentState?.refreshChecklist();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          MedicationStats(key: _statsKey),

          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Icon(
                Icons.stacked_line_chart,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '월별 복용률',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const _MonthlyAdherenceChart(),

          const SizedBox(height: AppSizes.lg),
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
          _TodayIntakeChecklist(
            key: _checklistKey,
            onChecklistChanged: refreshStats,
          ),

          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                '약상자 상태',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const PillboxStats(),

          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class _MedicationTab extends StatefulWidget {
  const _MedicationTab({super.key});

  @override
  State<_MedicationTab> createState() => _MedicationTabState();
}

class _MedicationTabState extends State<_MedicationTab> {
  // 실제 데이터는 등록 시(onMedicationAdded) 추가됨
  final List<Map<String, dynamic>> _registeredMedications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = ApiClient();
      final response = await api.getMedications();
      final List<Map<String, dynamic>> meds = List<Map<String, dynamic>>.from(
        response['medications'] ?? [],
      );
      final mapped = meds.map(_mapMedication).toList();
      if (!mounted) return;
      setState(() {
        _registeredMedications
          ..clear()
          ..addAll(mapped);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '약 목록을 불러오지 못했습니다. 다시 시도해주세요.';
      });
    }
  }

  void addMedication(Map<String, dynamic> medication) {
    setState(() {
      _registeredMedications.insert(0, medication);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('약이 추가되었습니다.'),
        backgroundColor: AppColors.primary,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMedications();
      }
    });
  }

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadMedications,
                  color: AppColors.primary,
                  child: _registeredMedications.isEmpty
                      ? _buildEmptyState()
                      : _buildMedicationList(),
                ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      physics: const AlwaysScrollableScrollPhysics(),
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
                    builder: (context) => MedicationRegistrationScreen(
                      onMedicationAdded: (medication) {
                        // 약이 추가될 때마다 리스트에 추가
                        addMedication(medication);
                      },
                    ),
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
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage ?? '약 목록을 불러오지 못했습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: _loadMedications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: _registeredMedications.length,
      itemBuilder: (context, index) {
        final medication = _registeredMedications[index];
        return _buildMedicationCard(medication, index);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication, int index) {
    final List<String> times =
        List<String>.from(medication['times'] ?? const <String>[]);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication['name'],
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        medication['manufacturer'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editMedication(index);
                    } else if (value == 'delete') {
                      _deleteMedication(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '복용 횟수',
                    medication['frequency'],
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: Container(), // 빈 공간
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            _buildInfoItem(
              '복용 시간',
              times.isEmpty ? '-' : times.join(', '),
              Icons.access_time,
            ),
            const SizedBox(height: AppSizes.sm),
            _buildInfoItem(
              '복용 기간',
              '${medication['startDate']} ~ ${medication['endDate']}',
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.xs),
        Expanded(
          child: Text(
            '$label: $value',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _editMedication(int index) {
    // TODO: 약 수정 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_registeredMedications[index]['name']} 수정 기능은 준비 중입니다.',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약 삭제'),
        content: Text('${_registeredMedications[index]['name']}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _registeredMedications.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('약이 삭제되었습니다.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              splashFactory: NoSplash.splashFactory,
            ),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
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

  Map<String, dynamic> _mapMedication(Map<String, dynamic> medication) {
    final List<dynamic> timesDynamic =
        (medication['dosage_times'] ?? medication['dosageTimes'] ?? []) as List;
    final List<String> times = timesDynamic.map((e) => e.toString()).toList();
    final String startDate =
        (medication['start_date'] ?? medication['startDate'] ?? '')
            .toString();
    final bool isIndefinite =
        (medication['is_indefinite'] ?? medication['isIndefinite']) == true;
    final String endDateRaw =
        (medication['end_date'] ?? medication['endDate'] ?? '').toString();

    return {
      'id': medication['id'],
      'name': medication['drug_name'] ?? medication['name'] ?? '이름 미상',
      'manufacturer': medication['manufacturer'] ?? '-',
      'times': times,
      'frequency': medication['frequency'] is num
          ? '하루 ${(medication['frequency'] as num).toInt()}회'
          : (medication['frequency']?.toString() ?? '정보 없음'),
      'startDate': startDate.isEmpty ? '-' : startDate,
      'endDate': isIndefinite
          ? '무기한'
          : (endDateRaw.isEmpty ? '-' : endDateRaw),
    };
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
  final VoidCallback? onToggle;
  final Widget? trailing;

  const _MedicationItem({
    required this.name,
    required this.time,
    required this.isTaken,
    this.onToggle,
    this.trailing,
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

              // 부모 콜백 호출하여 서버 기록 반영
              widget.onToggle?.call();
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
          if (widget.trailing != null) ...[
            const SizedBox(width: AppSizes.md),
            widget.trailing!,
          ],
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

class _MonthlyAdherenceChart extends StatefulWidget {
  const _MonthlyAdherenceChart();

  @override
  State<_MonthlyAdherenceChart> createState() => _MonthlyAdherenceChartState();
}

class _MonthlyAdherenceChartState extends State<_MonthlyAdherenceChart> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _months = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final data = await api.getMonthlyAdherenceStats();
      final list = List<Map<String, dynamic>>.from(data['months'] ?? []);
      if (mounted) {
        setState(() {
          _months = list.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _months = const [];
        });
      }
    }
  }

  double _toPercent01(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return (value.toDouble() / 100.0).clamp(0.0, 1.0);
    final String s = value.toString();
    final double? parsed = double.tryParse(s);
    if (parsed == null) return 0.0;
    return (parsed / 100.0).clamp(0.0, 1.0);
  }

  String _formatMonth(String monthStr) {
    if (monthStr.length > 5) {
      return monthStr.substring(5);
    }
    return monthStr;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_months.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          '표시할 월별 데이터가 없습니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _months
                .map(
                  (m) => Expanded(
                    child: Column(
                      children: [
                        _Bar(percent: _toPercent01(m['adherence_pct'])),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          _formatMonth((m['month'] ?? '').toString()),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double percent; // 0.0 ~ 1.0
  const _Bar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final double clamped = percent.clamp(0.0, 1.0);
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 120 * clamped,
          width: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _TodayIntakeChecklist extends StatefulWidget {
  final VoidCallback? onChecklistChanged;

  const _TodayIntakeChecklist({super.key, this.onChecklistChanged});

  @override
  State<_TodayIntakeChecklist> createState() => _TodayIntakeChecklistState();
}

class _TodayIntakeChecklistState extends State<_TodayIntakeChecklist> {
  bool _isLoading = true;
  List<_PlannedIntake> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refreshChecklist() async {
    setState(() {
      _isLoading = true;
    });
    await _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final medsResp = await api.getMedications();
      final List<Map<String, dynamic>> meds = List<Map<String, dynamic>>.from(
        medsResp['medications'] ?? [],
      );
      final DateTime now = DateTime.now();
      final DateTime start = DateTime(now.year, now.month, now.day);
      final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final intakesResp = await api.getMedicationIntakes(
        startDate: start.toIso8601String(),
        endDate: end.toIso8601String(),
      );
      final List<Map<String, dynamic>> intakes =
          List<Map<String, dynamic>>.from(intakesResp['intakes'] ?? []);

      List<_PlannedIntake> planned = [];
      for (final m in meds) {
        final int id = (m['id'] as int);
        final String name = (m['drug_name'] ?? m['name'] ?? '').toString();
        final List times = (m['dosage_times'] as List?) ?? const [];
        for (final t in times) {
          final String timeStr = t.toString();
          final DateTime intakeDt = _composeToday(timeStr);
          final bool taken = _matchTaken(intakes, id, intakeDt);
          planned.add(
            _PlannedIntake(
              medicationId: id,
              medicationName: name,
              intakeTime: intakeDt,
              timeLabel: timeStr,
              isTaken: taken,
            ),
          );
        }
      }
      setState(() {
        _items = planned;
        _isLoading = false;
        _error = null;
      });
      widget.onChecklistChanged?.call();
    } catch (e) {
      setState(() {
        _items = const [];
        _isLoading = false;
        _error = '네트워크 오류로 데이터를 불러오지 못했습니다.';
      });
    }
  }

  DateTime _composeToday(String hhmm) {
    final DateTime n = DateTime.now();
    final parts = hhmm.split(':');
    final int h = int.tryParse(parts[0]) ?? 0;
    final int m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(n.year, n.month, n.day, h, m);
  }

  bool _matchTaken(List<Map<String, dynamic>> intakes, int medId, DateTime dt) {
    final String prefix = dt.toIso8601String().substring(
      0,
      16,
    ); // yyyy-MM-ddTHH:mm
    for (final it in intakes) {
      final int mid = (it['medication_id'] ?? it['medicationId'] ?? 0) as int;
      if (mid != medId) continue;
      final String when = (it['intake_time'] ?? it['intakeTime'] ?? '')
          .toString();
      if (when.startsWith(prefix)) {
        return (it['is_taken'] ?? it['isTaken'] ?? false) == true;
      }
    }
    return false;
  }

  Future<void> _toggle(_PlannedIntake p) async {
    try {
      final api = ApiClient();
      await api.recordMedicationIntake(
        medicationId: p.medicationId,
        intakeTime: p.intakeTime.toIso8601String(),
        isTaken: !p.isTaken,
      );
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : (_error != null
                ? Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _error!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  )
                : (_items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Text(
                            '등록된 복약 체크 항목이 없습니다.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) {
                            final p = _items[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              child: _MedicationItem(
                                name: p.medicationName,
                                time: p.timeLabel,
                                isTaken: p.isTaken,
                                onToggle: () => _toggle(p),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.chat,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ChatbotScreen(
                                          medicationId: p.medicationId,
                                          medicationName: p.medicationName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => _buildDivider(),
                          itemCount: _items.length,
                        ))),
    );
  }
}

class _PlannedIntake {
  final int medicationId;
  final String medicationName;
  final DateTime intakeTime;
  final String timeLabel;
  final bool isTaken;

  const _PlannedIntake({
    required this.medicationId,
    required this.medicationName,
    required this.intakeTime,
    required this.timeLabel,
    required this.isTaken,
  });
}
