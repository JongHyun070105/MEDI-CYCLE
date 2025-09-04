import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class MedicationBoxScreen extends StatefulWidget {
  const MedicationBoxScreen({super.key});

  @override
  State<MedicationBoxScreen> createState() => _MedicationBoxScreenState();
}

class _MedicationBoxScreenState extends State<MedicationBoxScreen> {
  final bool _isConnected = true;
  bool _isLocked = true;
  final bool _hasMedication = true;
  int _batteryLevel = 42;

  @override
  Widget build(BuildContext context) {
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
            _isConnected ? '마지막 연결: 방금 전' : '연결을 확인해주세요',
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
          title: '배터리',
          value: '$_batteryLevel%',
          icon: _getBatteryIcon(),
          color: _getBatteryColor(),
          showProgress: true,
          progress: _batteryLevel / 100,
        ),
        const SizedBox(height: AppSizes.md),
        _buildStatusItem(
          title: '잠금 상태',
          value: _isLocked ? '잠김' : '열림',
          icon: _isLocked ? Icons.lock : Icons.lock_open,
          color: _isLocked ? AppColors.error : AppColors.success,
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
              child: ElevatedButton.icon(
                onPressed: _isLocked ? _unlockBox : _lockBox,
                icon: Icon(_isLocked ? Icons.lock_open : Icons.lock),
                label: Text(_isLocked ? '상자 열기' : '상자 잠그기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLocked
                      ? AppColors.primary
                      : AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _refreshStatus,
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
        Text(
          '최근 활동',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _buildActivityItem(
          time: '2분 전',
          action: '약물 감지됨',
          icon: Icons.medication,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildActivityItem(
          time: '1시간 전',
          action: '상자가 잠김',
          icon: Icons.lock,
          color: AppColors.error,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildActivityItem(
          time: '3시간 전',
          action: '배터리 50% 이하',
          icon: Icons.battery_alert,
          color: AppColors.warning,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildActivityItem(
          time: '1일 전',
          action: '상자가 열림',
          icon: Icons.lock_open,
          color: AppColors.primary,
        ),
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

  IconData _getBatteryIcon() {
    if (_batteryLevel > 50) return Icons.battery_full;
    if (_batteryLevel > 20) return Icons.battery_6_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor() {
    if (_batteryLevel > 50) return AppColors.success;
    if (_batteryLevel > 20) return AppColors.warning;
    return AppColors.error;
  }

  void _refreshStatus() {
    setState(() {
      // 실제로는 API 호출로 상태를 새로고침
      _batteryLevel = 42 + (DateTime.now().millisecond % 20);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('상태를 새로고침했습니다'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _lockBox() {
    setState(() {
      _isLocked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('약 상자가 잠겼습니다'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _unlockBox() {
    setState(() {
      _isLocked = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('약 상자가 열렸습니다'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
