import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/pillbox_service.dart';
import '../../../../shared/models/pillbox_model.dart';

class PillboxStats extends StatefulWidget {
  const PillboxStats({super.key});

  @override
  State<PillboxStats> createState() => _PillboxStatsState();
}

class _PillboxStatsState extends State<PillboxStats> {
  bool _isLoading = true;
  PillboxStatus? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await pillboxService.getStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _status = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_status == null) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                '약상자가 등록되지 않았습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final status = _status!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: status.detected
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      status.detected ? Icons.check_circle : Icons.cancel,
                      color: status.detected ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    '약상자 상태',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                status.detected ? '감지됨' : '미감지',
                style: AppTextStyles.bodySmall.copyWith(
                  color: status.detected ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (status.batteryPercent != null) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getBatteryIcon(status.batteryPercent!),
                      color: _getBatteryColor(status.batteryPercent!),
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      '배터리',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${status.batteryPercent}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getBatteryColor(status.batteryPercent!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            LinearProgressIndicator(
              value: status.batteryPercent! / 100,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getBatteryColor(status.batteryPercent!),
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    status.isLocked ? Icons.lock : Icons.lock_open,
                    color: status.isLocked ? AppColors.error : AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    '잠금 상태',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                status.isLocked ? '잠김' : '열림',
                style: AppTextStyles.bodySmall.copyWith(
                  color: status.isLocked ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getBatteryIcon(int battery) {
    if (battery > 50) return Icons.battery_full;
    if (battery > 20) return Icons.battery_6_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int battery) {
    if (battery > 50) return AppColors.success;
    if (battery > 20) return AppColors.warning;
    return AppColors.error;
  }
}

