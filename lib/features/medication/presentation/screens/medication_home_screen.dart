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
import '../../../../shared/services/notification_service.dart';

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
  final GlobalKey<MedicationBoxScreenState> _medicationBoxScreenKey =
      GlobalKey<MedicationBoxScreenState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
            _MedicationTab(
            key: _medicationTabKey,
            onMedicationDeleted: () {
              final homeTabState = _homeTabKey.currentState;
              if (homeTabState != null && homeTabState._hasCompletedInitialLoad) {
                homeTabState.refreshAll();
              }
            },
            onMedicationUpdated: () {
              final homeTabState = _homeTabKey.currentState;
              if (homeTabState != null && homeTabState._hasCompletedInitialLoad) {
                homeTabState.refreshAll();
              }
            },
          ),
          _HomeTab(key: _homeTabKey),
          _PharmacyTab(medicationBoxScreenKey: _medicationBoxScreenKey),
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
                final int previousIndex = _currentIndex;
            setState(() {
              _currentIndex = index;
            });
                // 홈 탭으로 이동할 때마다 새로고침 (다른 탭에서만, 챗봇 제외)
                // 챗봇은 FAB으로 이동하므로 여기서는 처리하지 않음
                // 초기 로딩이 완료된 후에만 새로고침 수행
                if (index == 2 && previousIndex != 2) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final homeTabState = _homeTabKey.currentState;
                    if (homeTabState != null) {
                      // 초기 로딩이 완료된 경우에만 새로고침
                      if (homeTabState._hasCompletedInitialLoad && !homeTabState.isRefreshing) {
                        homeTabState.refreshAll();
                      }
                      // 연결 상태와 약물 감지도 새로고침 (약상자 상태)
                      homeTabState.refreshPillboxStats();
                    }
                  });
                }
                // 약 상자 탭으로 이동할 때마다 새로고침
                if (index == 3 && previousIndex != 3) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final boxScreen = _medicationBoxScreenKey.currentState;
                    if (boxScreen != null) {
                      // 로딩 상태를 초기화하고 다시 로드
                      // 이미 로드된 경우라도 다시 로드하여 버튼이 활성화되도록 함
                      boxScreen.refresh();
                    }
                  });
                }
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
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: '인사이트',
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
                    final homeTabState = _homeTabKey.currentState;
                    if (homeTabState != null && homeTabState._hasCompletedInitialLoad) {
                      homeTabState.refreshAll();
                    }
                  },
                ),
              ),
            );
            if (result != null && result is Map<String, dynamic>) {
              _medicationTabKey.currentState?.addMedication(result);
              final homeTabState = _homeTabKey.currentState;
              if (homeTabState != null && homeTabState._hasCompletedInitialLoad) {
                homeTabState.refreshAll();
              }
            }
                // 약 등록 후 홈 탭으로 자동 이동 및 새로고침
                if (result != null) {
                  setState(() {
                    _currentIndex = 2; // 홈 탭으로 이동
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final homeTabState = _homeTabKey.currentState;
                    if (homeTabState != null && homeTabState._hasCompletedInitialLoad) {
                      homeTabState.refreshAll();
                    }
                  });
                }
          } else {
                // 다른 탭일 때는 챗봇으로 이동 (새로고침 없이)
                await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
                // 챗봇에서 돌아올 때는 새로고침하지 않음 (인디케이터 없이)
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
        ),
      ],
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
  final GlobalKey<PillboxStatsState> _pillboxStatsKey =
      GlobalKey<PillboxStatsState>();
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _hasCompletedInitialLoad = false;
  
  // 외부에서 새로고침 상태 확인용 getter
  bool get isRefreshing => _isRefreshing;
  bool get isInitialLoading => _isInitialLoading;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 약간의 지연을 주어 모든 컴포넌트가 로딩을 시작하도록 함
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 통계, 체크리스트, 약상자 상태를 동시에 로딩
    await Future.wait([
      refreshStats(),
      refreshChecklist(),
      refreshPillboxStats(),
    ]);
    
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
        _hasCompletedInitialLoad = true;
      });
    }
  }

  Future<void> refreshAll() async {
    // 초기 로딩이 완료되지 않았으면 무시
    if (!_hasCompletedInitialLoad) return;
    
    // 이미 새로고침 중이면 무시
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // 통계, 체크리스트, 약상자 상태를 동시에 새로고침
      await Future.wait([
        refreshStats(),
        refreshChecklist(),
        refreshPillboxStats(),
      ]);
    } catch (e) {
      debugPrint('새로고침 중 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> refreshStats() async {
    await _statsKey.currentState?.refreshStatistics();
  }

  Future<void> refreshChecklist() async {
    await _checklistKey.currentState?.refreshChecklist();
  }

  Future<void> refreshPillboxStats() async {
    await _pillboxStatsKey.currentState?.refresh();
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
          PillboxStats(key: _pillboxStatsKey),

          const SizedBox(height: AppSizes.lg),
          _TodayIntakeChecklist(
            key: _checklistKey,
            onChecklistChanged: refreshStats,
          ),

          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class _MedicationTab extends StatefulWidget {
  final VoidCallback? onMedicationDeleted;
  final VoidCallback? onMedicationUpdated;

  const _MedicationTab({super.key, this.onMedicationDeleted, this.onMedicationUpdated});

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        // 서버에서 최신 목록 다시 로드
        await _loadMedications();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('약이 추가되었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        // 에러 발생 시 무시 (이미 dispose된 경우)
        debugPrint('약 추가 후 새로고침 중 오류: $e');
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
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: AppSizes.xl * 3, // FAB과 하단 네비게이션 바 고려한 넉넉한 패딩
      ),
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
    // 시간 순서대로 정렬
    final List<String> sortedTimes = List<String>.from(times);
    sortedTimes.sort((a, b) {
      final partsA = a.split(':');
      final partsB = b.split(':');
      final hourA = int.tryParse(partsA[0]) ?? 0;
      final minuteA = partsA.length > 1 ? (int.tryParse(partsA[1]) ?? 0) : 0;
      final hourB = int.tryParse(partsB[0]) ?? 0;
      final minuteB = partsB.length > 1 ? (int.tryParse(partsB[1]) ?? 0) : 0;
      if (hourA != hourB) {
        return hourA.compareTo(hourB);
      }
      return minuteA.compareTo(minuteB);
    });
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
                    Icons.repeat,
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
              sortedTimes.isEmpty ? '-' : sortedTimes.join(', '),
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

  void _deleteMedication(int index) async {
    final medication = _registeredMedications[index];
    final medicationId = medication['id'] as int?;
    
    if (medicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('약 ID를 찾을 수 없습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약 삭제'),
        content: Text('${medication['name']}을(를) 삭제하시겠습니까?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              splashFactory: NoSplash.splashFactory,
            ),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final api = ApiClient();
      await api.deleteMedication(medicationId);
      
      // 알림 취소
      try {
        await notificationService.cancelMedicationNotifications(medicationId);
      } catch (e) {
        debugPrint('알림 취소 실패: $e');
      }
      
      // 서버에서 최신 목록 다시 로드
      await _loadMedications();
      
      // 메인 화면 업데이트
      widget.onMedicationDeleted?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('약이 삭제되었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('약 삭제 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
    } catch (e) {
      return dateStr; // 파싱 실패 시 원본 반환
    }
  }

  Map<String, dynamic> _mapMedication(Map<String, dynamic> medication) {
    final List<dynamic> timesDynamic =
        (medication['dosage_times'] ?? medication['dosageTimes'] ?? []) as List;
    final List<String> times = timesDynamic.map((e) => e.toString()).toList();
    // 시간 순서대로 정렬
    times.sort((a, b) {
      final partsA = a.split(':');
      final partsB = b.split(':');
      final hourA = int.tryParse(partsA[0]) ?? 0;
      final minuteA = partsA.length > 1 ? (int.tryParse(partsA[1]) ?? 0) : 0;
      final hourB = int.tryParse(partsB[0]) ?? 0;
      final minuteB = partsB.length > 1 ? (int.tryParse(partsB[1]) ?? 0) : 0;
      if (hourA != hourB) {
        return hourA.compareTo(hourB);
      }
      return minuteA.compareTo(minuteB);
    });
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
      'startDate': startDate.isEmpty ? '-' : _formatDate(startDate),
      'endDate': isIndefinite
          ? '무기한'
          : (endDateRaw.isEmpty ? '-' : _formatDate(endDateRaw)),
    };
  }
}

class _DisposalTab extends StatelessWidget {
  const _DisposalTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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

class _PharmacyTab extends StatefulWidget {
  final GlobalKey<MedicationBoxScreenState>? medicationBoxScreenKey;
  
  const _PharmacyTab({this.medicationBoxScreenKey});

  @override
  State<_PharmacyTab> createState() => _PharmacyTabState();
}

class _PharmacyTabState extends State<_PharmacyTab> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('약 상자 상태'),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: MedicationBoxScreen(key: widget.medicationBoxScreenKey),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final GlobalKey<AiFeedbackScreenState> _aiFeedbackScreenKey = GlobalKey<AiFeedbackScreenState>();
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('인사이트'),
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
                    Tab(text: '대시보드'),
                    Tab(text: 'AI'),
                  ],
                ),
              ),
            ),
            body: AiFeedbackScreen(key: _aiFeedbackScreenKey),
          ),
        ),
      ],
    );
  }
}

// 투두리스트 스타일의 약물 항목 위젯
class _MedicationItem extends StatefulWidget {
  final String name;
  final String time;
  final bool isTaken;
  final DateTime? intakeTime;
  final VoidCallback? onToggle;
  final Widget? trailing;

  const _MedicationItem({
    required this.name,
    required this.time,
    required this.isTaken,
    this.intakeTime,
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
            child: Text(
              widget.name,
              style: AppTextStyles.bodyLarge.copyWith(
                color: _isTaken
                    ? AppColors.textSecondary
                    : AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: _isTaken ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // 복용 시간 10분 전까지는 체크 불가 (복용 완료 후 취소는 가능)
              if (!_isTaken && widget.intakeTime != null) {
                final now = DateTime.now();
                final allowedTime = widget.intakeTime!.subtract(const Duration(minutes: 10));
                if (now.isBefore(allowedTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '복용 시간 10분 전부터 체크할 수 있습니다. (${widget.time})',
                      ),
                      backgroundColor: AppColors.warning,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
              }

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
    // 개별 로딩 인디케이터 제거 - 페이지 전체 로딩으로 통합
    if (_isLoading) {
      return const SizedBox.shrink();
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
  Map<String, bool> _expandedGroups = {}; // 시간대별 토글 상태

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

      // 오늘 날짜 기준 활성 약만 필터링
      final DateTime today = DateTime.now();
      final List<Map<String, dynamic>> activeMeds = meds.where((m) {
        final String? startStr = (m['start_date'] ?? m['startDate'])?.toString();
        final String? endStr = (m['end_date'] ?? m['endDate'])?.toString();
        final bool isIndefinite = (m['is_indefinite'] ?? m['isIndefinite']) == true;
        if (startStr == null || startStr.isEmpty) return false;
        final DateTime? start = DateTime.tryParse(startStr);
        final DateTime? end = endStr != null && endStr.isNotEmpty
            ? DateTime.tryParse(endStr)
            : null;
        if (start == null) return false;
        
        // 시작일 체크: 오늘이 시작일 이후거나 같으면 true
        final DateTime startDate = DateTime(start.year, start.month, start.day);
        final bool afterStart = !today.isBefore(startDate);
        
        // 종료일 체크: 무기한이거나 종료일이 없으면 true, 종료일이 있으면 오늘이 종료일 이하이면 true
        final bool beforeEnd = isIndefinite || end == null
            ? true
            : !today.isAfter(DateTime(end.year, end.month, end.day));
        
        return afterStart && beforeEnd;
      }).toList();

      List<_PlannedIntake> planned = [];
      for (final m in activeMeds) {
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
      // 시간 순으로 정렬
      planned.sort((a, b) => a.intakeTime.compareTo(b.intakeTime));
      
      // 시간대별 그룹화 및 기본 확장 상태 설정
      final Map<String, bool> expandedGroups = {};
      for (final item in planned) {
        final timeKey = item.timeLabel;
        if (!expandedGroups.containsKey(timeKey)) {
          expandedGroups[timeKey] = true; // 기본적으로 펼쳐진 상태
        }
      }
      
      if (!mounted) return;
      setState(() {
        _items = planned;
        _expandedGroups = expandedGroups;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
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
      
      // 통계를 즉시 업데이트 (비동기로 처리하되, 먼저 시작)
      widget.onChecklistChanged?.call();
      
      // 체크리스트도 동시에 새로고침
      await _load();
    } catch (_) {}
  }

  Widget _buildGroupedChecklist() {
    // 시간대별로 그룹화
    final Map<String, List<_PlannedIntake>> grouped = {};
    for (final item in _items) {
      final timeKey = item.timeLabel;
      if (!grouped.containsKey(timeKey)) {
        grouped[timeKey] = [];
      }
      grouped[timeKey]!.add(item);
    }
    
    // 시간대 순서 정렬
    final sortedTimes = grouped.keys.toList()
      ..sort((a, b) {
        final timeA = _composeToday(a);
        final timeB = _composeToday(b);
        return timeA.compareTo(timeB);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedTimes.map((timeKey) {
        final items = grouped[timeKey]!;
        final isExpanded = _expandedGroups[timeKey] ?? true;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간대 헤더 (토글 가능)
            InkWell(
              onTap: () {
                setState(() {
                  _expandedGroups[timeKey] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      timeKey,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // 약 목록 (펼쳐져 있을 때만 표시)
            if (isExpanded)
              ...items.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.md,
                    right: AppSizes.md,
                    bottom: AppSizes.sm,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: AppSizes.sm),
                      const Text(
                        '- ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: _MedicationItem(
                          name: p.medicationName,
                          time: p.timeLabel,
                          isTaken: p.isTaken,
                          intakeTime: p.intakeTime,
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
                      ),
                    ],
                  ),
                );
              }).toList(),
            if (timeKey != sortedTimes.last)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
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
          ),
          // 내용
          if (_isLoading)
            const SizedBox.shrink() // 개별 로딩 인디케이터 제거
          else if (_error != null)
            Padding(
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
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Text(
                '등록된 복약 체크 항목이 없습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            _buildGroupedChecklist(),
        ],
      ),
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
