import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/rpi_pillbox_service.dart';

class PillboxStats extends StatefulWidget {
  const PillboxStats({super.key});

  @override
  State<PillboxStats> createState() => PillboxStatsState();
}

class PillboxStatsState extends State<PillboxStats> {
  final RpiPillboxService _rpiService = rpiPillboxService;
  bool _isConnected = false;
  bool _hasMedication = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  /// 외부에서 새로고침 호출 가능
  Future<void> refresh() async {
    await _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      // 타임아웃을 3초로 설정
      final isConnected = await _rpiService.isConnected()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      final status = await _rpiService.getStatus()
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (!mounted) return;
      setState(() {
        _isConnected = isConnected;
        _hasMedication = status?.hasMedication ?? false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('약상자 상태 로드 실패: $e');
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _hasMedication = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 연결 상태 카드
        Expanded(
          child: _buildStatusCard(
            icon: _isLoading
                ? Icons.bluetooth_searching
                : (_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            iconColor: _isLoading
                ? AppColors.textSecondary
                : (_isConnected ? AppColors.success : AppColors.error),
            backgroundColor: _isLoading
                ? AppColors.textSecondary.withOpacity(0.1)
                : (_isConnected
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1)),
            title: '연결 상태',
            status: _isLoading
                ? '확인 중...'
                : (_isConnected ? '연결됨' : '연결 끊김'),
            statusColor:
                _isLoading ? AppColors.textSecondary : (_isConnected ? AppColors.success : AppColors.error),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        // 약물 감지 카드
        Expanded(
          child: _buildStatusCard(
            icon: _isLoading
                ? Icons.search
                : (_hasMedication ? Icons.check_circle : Icons.cancel),
            iconColor: _isLoading
                ? AppColors.textSecondary
                : (_hasMedication ? AppColors.success : AppColors.error),
            backgroundColor: _isLoading
                ? AppColors.textSecondary.withOpacity(0.1)
                : (_hasMedication
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1)),
            title: '약물 감지',
            status: _isLoading
                ? '확인 중...'
                : (_hasMedication ? '감지됨' : '미감지'),
            statusColor: _isLoading
                ? AppColors.textSecondary
                : (_hasMedication ? AppColors.success : AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double iconSize = (MediaQuery.of(context).size.width * 0.12).clamp(40.0, 56.0);
              return Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize * 0.5,
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            status,
            style: AppTextStyles.bodyMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

