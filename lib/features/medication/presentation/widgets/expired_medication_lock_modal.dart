import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExpiredMedicationLockModal extends StatelessWidget {
  final VoidCallback onConfirmed;

  const ExpiredMedicationLockModal({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('유통기한 지난 약 잠금'),
      content: Text(
        '유통기한이 지난 약이 감지되어 잠금 상태입니다.\n이미 폐기하셨다면 확인을 눌러 잠금 해제를 허용해주세요.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            splashFactory: NoSplash.splashFactory,
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}


