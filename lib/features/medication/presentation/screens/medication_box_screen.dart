import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/rpi_pillbox_service.dart';

class MedicationBoxScreen extends StatefulWidget {
  const MedicationBoxScreen({super.key});

  @override
  State<MedicationBoxScreen> createState() => MedicationBoxScreenState();
}

class MedicationBoxScreenState extends State<MedicationBoxScreen> {
  final RpiPillboxService _rpiService = rpiPillboxService;
  bool _isConnected = false;
  bool _isLoading = true;
  bool _hasMedication = false;
  bool _isLocked = true; // 더미데이터: 잠금 상태
  DateTime? _lastSeenDateTime;
  List<RpiPillboxLog> _recentLogs = [];

  String _formatLastSeen(DateTime? dt) {
    if (dt == null) return '알 수 없음';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}초 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  /// 외부에서 새로고침 호출 가능
  void refresh() {
    // 로딩 중이어도 강제로 새로고침 시작 (버튼이 비활성화된 상태 해결)
    _loadStatus();
  }
  
  
  /// 외부에서 로딩 완료 여부 확인 (메인화면에서 사용)
  bool get hasLoadedOnce => _hasLoadedOnce;
  
  /// 외부에서 로딩 상태 확인 (오버레이 표시용)
  bool get isLoading => _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_hasLoadedOnce) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        100,
      ), // 하단 패딩 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스마트 약 상자 연결 상태
          _buildConnectionStatus(),
          const SizedBox(height: AppSizes.xl),

          // 상태 정보
          _buildStatusSection(),
          const SizedBox(height: AppSizes.xl),

          // 제어 버튼들
          _buildControlButtons(),
          const SizedBox(height: AppSizes.xl),

          // 최근 활동
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: _isConnected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: _isConnected ? AppColors.primary : AppColors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isConnected ? AppColors.primary : AppColors.error,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(Icons.inventory_2, size: 40, color: Colors.white),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            _isConnected ? '스마트 약 상자 연결됨' : '스마트 약 상자 연결 끊김',
            style: AppTextStyles.h5.copyWith(
              color: _isConnected ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _isConnected
                ? (_lastSeenDateTime != null
                    ? '마지막 연결: ${_formatLastSeen(_lastSeenDateTime)}'
                    : '마지막 연결: 확인 중...')
                : '연결을 확인해주세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상태 정보',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _buildStatusItem(
          title: '약물 감지',
          value: _hasMedication ? '감지됨' : '감지 안됨',
          icon: _hasMedication ? Icons.check_circle : Icons.cancel,
          color: _hasMedication ? AppColors.success : AppColors.error,
        ),
        const SizedBox(height: AppSizes.md),
        _buildStatusItem(
          title: '잠금 상태',
          value: _isLocked ? '잠김' : '열림',
          icon: _isLocked ? Icons.lock : Icons.lock_open,
          color: _isLocked ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool showProgress = false,
    double? progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                if (showProgress && progress != null) ...[
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                  const SizedBox(height: AppSizes.xs),
                ],
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제어',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        // 더미: 잠금/잠금 해제 기능
                        setState(() {
                          _isLocked = !_isLocked;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isLocked
                                ? '약상자가 잠겼습니다'
                                : '약상자 잠금이 해제되었습니다'),
                            backgroundColor: _isLocked
                                ? AppColors.success
                                : AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                icon: Icon(_isLocked ? Icons.lock : Icons.lock_open),
                label: Text(_isLocked ? '잠금 해제' : '잠금'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isLocked
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  foregroundColor: _isLocked
                      ? AppColors.success
                      : AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _refreshStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('상태 새로고침'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 활동',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        if (_recentLogs.isEmpty && !_isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Text(
                '활동 로그가 없습니다',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ..._recentLogs.take(10).map((log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: _buildActivityItem(
                  time: log.timeFormatted,
                  action: log.hasMedication
                      ? '약물 감지됨'
                      : '약물 미감지',
                  icon: log.hasMedication ? Icons.medication : Icons.cancel,
                  color: log.hasMedication
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              )),
      ],
    );
  }

  Widget _buildActivityItem({
    required String time,
    required String action,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 타임아웃을 포함한 상태 조회 (최대 3초)
      final isConnected = await _rpiService.isConnected()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      final status = await _rpiService.getStatus()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      final logs = await _rpiService.getLogs(limit: 20)
          .timeout(const Duration(seconds: 3), onTimeout: () => <RpiPillboxLog>[]);

      if (!mounted) return;
      // 로그를 최신순으로 정렬 (시간 역순)
      logs.sort((a, b) {
        final aTime = a.timestamp;
        final bTime = b.timestamp;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // 최신순 (내림차순)
      });
      
      setState(() {
        _isConnected = isConnected;
        _hasMedication = status?.hasMedication ?? false;
        _lastSeenDateTime = status?.lastSeenDateTime;
        _recentLogs = logs;
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      debugPrint('약상자 상태 로드 실패: $e');
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _hasMedication = false;
        _recentLogs = [];
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

  Future<void> _refreshStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 상태와 로그를 함께 새로고침 (타임아웃 추가)
      final isConnected = await _rpiService.isConnected()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      final status = await _rpiService.getStatus()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      final logs = await _rpiService.getLogs(limit: 20)
          .timeout(const Duration(seconds: 3), onTimeout: () => <RpiPillboxLog>[]);

      if (!mounted) return;
      // 로그를 최신순으로 정렬 (시간 역순)
      logs.sort((a, b) {
        final aTime = a.timestamp;
        final bTime = b.timestamp;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // 최신순 (내림차순)
      });

      setState(() {
        _isConnected = isConnected;
        _hasMedication = status?.hasMedication ?? false;
        _lastSeenDateTime = status?.lastSeenDateTime;
        _recentLogs = logs; // 로그 새로고침
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isConnected
              ? '상태와 로그를 새로고침했습니다'
              : '서버에 연결할 수 없습니다'),
          backgroundColor:
              _isConnected ? AppColors.primary : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('약상자 상태 새로고침 실패: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('새로고침 중 오류가 발생했습니다'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
