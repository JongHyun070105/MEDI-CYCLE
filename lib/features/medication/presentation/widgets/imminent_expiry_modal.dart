import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';

class ImminentExpiryModal extends StatelessWidget {
  final List<Map<String, dynamic>> imminentMedications;

  const ImminentExpiryModal({
    super.key,
    required this.imminentMedications,
  });

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = AppResponsive.getDialogWidth(context);
    final Color primaryColor = AppColors.warning;
    
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
            Icons.warning_amber_rounded,
            color: primaryColor,
            size: 28,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              '유통기한 임박 약 알림',
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
                '다음 약들은 유통기한이 30일 이내로 임박했습니다.\n빠른 시일 내에 복용을 완료해주세요.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              ...imminentMedications.take(10).map((e) => _buildRow(e)),
              if (imminentMedications.length > 10)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text(
                    '외 ${imminentMedications.length - 10}건',
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
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> medication) {
    final String name = (medication['drug_name'] ?? '').toString();
    final String? expiryStr = medication['expiry_date']?.toString();
    
    String formattedDate = '-';
    int? daysLeft;
    if (expiryStr != null && expiryStr.isNotEmpty) {
      try {
        final DateTime? date = DateTime.tryParse(expiryStr);
        if (date != null) {
          formattedDate = '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
          daysLeft = date.difference(DateTime.now()).inDays;
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
          Row(
            children: [
              Text(
                '만료일: $formattedDate',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (daysLeft != null && daysLeft >= 0) ...[
                const SizedBox(width: AppSizes.xs),
                Text(
                  '(D-$daysLeft)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

