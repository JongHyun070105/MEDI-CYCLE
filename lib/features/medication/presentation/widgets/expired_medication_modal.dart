import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';

class ExpiredMedicationModal extends StatelessWidget {
  final List<Map<String, dynamic>> expiredMedications;
  final VoidCallback onGoDisposal;

  const ExpiredMedicationModal({
    super.key,
    required this.expiredMedications,
    required this.onGoDisposal,
  });

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = AppResponsive.getDialogWidth(context);
    final Color primaryColor = AppColors.error;
    
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: primaryColor,
          width: 2.0,
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.dangerous_outlined,
            color: primaryColor,
            size: 28,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              '유통기한 만료 약 알림',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '다음 약들은 유통기한이 지났습니다.\n복용을 중단하고 폐의약품 수거함에 버려주세요.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              ...expiredMedications.take(10).map((e) => _buildRow(e)),
              if (expiredMedications.length > 10)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text(
                    '외 ${expiredMedications.length - 10}건',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onGoDisposal();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('폐의약품 처리'),
        ),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> medication) {
    final String name = (medication['drug_name'] ?? '').toString();
    final String? expiryStr = medication['expiry_date']?.toString();
    
    String formattedDate = '-';
    if (expiryStr != null && expiryStr.isNotEmpty) {
      try {
        final DateTime? date = DateTime.tryParse(expiryStr);
        if (date != null) {
          formattedDate = '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
        }
      } catch (_) {
        formattedDate = expiryStr;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '만료일: $formattedDate',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

