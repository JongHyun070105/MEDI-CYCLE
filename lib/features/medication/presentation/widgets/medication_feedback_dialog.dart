import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/feedback_service.dart';

class MedicationFeedbackDialog extends StatefulWidget {
  final int medicationId;
  final int notificationId;
  final String medicationName;
  final DateTime scheduledTime;

  const MedicationFeedbackDialog({
    super.key,
    required this.medicationId,
    required this.notificationId,
    required this.medicationName,
    required this.scheduledTime,
  });

  @override
  State<MedicationFeedbackDialog> createState() =>
      _MedicationFeedbackDialogState();

  static Future<void> show({
    required BuildContext context,
    required int medicationId,
    required int notificationId,
    required String medicationName,
    required DateTime scheduledTime,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicationFeedbackDialog(
        medicationId: medicationId,
        notificationId: notificationId,
        medicationName: medicationName,
        scheduledTime: scheduledTime,
      ),
    );
  }
}

class _MedicationFeedbackDialogState extends State<MedicationFeedbackDialog> {
  bool _isLoading = false;
  bool? _taken;
  TimeOfDay? _actualTime;
  int? _satisfaction;

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoAlertDialog(
        title: Text(
          '${widget.medicationName} 복용 확인',
          style: AppTextStyles.h5,
        ),
        content: _buildContent(),
        actions: [
          if (_taken == null) ...[
            CupertinoDialogAction(
              onPressed: () => _handleTaken(true),
              child: const Text('복용 완료'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => _handleTaken(false),
              child: const Text('복용 안 함'),
            ),
          ] else ...[
            CupertinoDialogAction(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('제출'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        ],
      );
    } else {
      return AlertDialog(
        title: Text(
          '${widget.medicationName} 복용 확인',
          style: AppTextStyles.h5,
        ),
        content: _buildContent(),
        actions: _buildActions(),
      );
    }
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_taken == null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              '약을 복용하셨나요?',
              style: AppTextStyles.bodyMedium,
            ),
          ] else ...[
            const SizedBox(height: AppSizes.md),
            // 실제 복용 시간 선택
            GestureDetector(
              onTap: _taken == true ? _selectActualTime : null,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      _actualTime != null
                          ? '${_actualTime!.hour.toString().padLeft(2, '0')}:${_actualTime!.minute.toString().padLeft(2, '0')}'
                          : '실제 복용 시간 선택 (선택사항)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _actualTime != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            // 만족도 선택
            Text(
              '만족도 (선택사항)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _satisfaction = rating;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _satisfaction == rating
                          ? AppColors.primary
                          : AppColors.borderLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _satisfaction == rating
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rating',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _satisfaction == rating
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_taken == null) {
      return [
        TextButton(
          onPressed: () => _handleTaken(false),
          child: Text(
            '복용 안 함',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.red,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleTaken(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text(
            '복용 완료',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  '제출',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ];
    }
  }

  void _handleTaken(bool taken) {
    setState(() {
      _taken = taken;
      if (taken) {
        // 기본값으로 현재 시간 설정
        final now = DateTime.now();
        _actualTime = TimeOfDay.fromDateTime(now);
      }
    });
  }

  Future<void> _selectActualTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _actualTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _actualTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_taken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 복용 시간을 HH:MM 형식으로 변환
      String? actualTimeStr;
      if (_taken == true && _actualTime != null) {
        actualTimeStr =
            '${_actualTime!.hour.toString().padLeft(2, '0')}:${_actualTime!.minute.toString().padLeft(2, '0')}';
      }

      // 약물 시간을 분 단위로 변환
      int? medicationTimeInMinutes;
      if (_taken == true && _actualTime != null) {
        medicationTimeInMinutes =
            _actualTime!.hour * 60 + _actualTime!.minute;
      }

      // 스케줄된 시간을 분 단위로 변환
      final scheduledTimeInMinutes =
          widget.scheduledTime.hour * 60 + widget.scheduledTime.minute;

      await feedbackService.submitFeedback(
        medicationId: widget.medicationId,
        notificationId: widget.notificationId,
        taken: _taken!,
        actualTime: actualTimeStr,
        medicationTime: medicationTimeInMinutes,
        mealTime: scheduledTimeInMinutes, // 스케줄된 시간을 meal_time으로 사용
        satisfaction: _satisfaction,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _taken == true
                ? '복용 완료가 기록되었습니다'
                : '복용하지 않음이 기록되었습니다',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('피드백 제출 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

