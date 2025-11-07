import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';

class MedicationPeriodEndModal extends StatelessWidget {
  final List<Map<String, dynamic>> endedMedications;

  const MedicationPeriodEndModal({
    super.key,
    required this.endedMedications,
  });

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = AppResponsive.getDialogWidth(context);
    final Color primaryColor = AppColors.primary;
    
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
            Icons.check_circle_outline,
            color: primaryColor,
            size: 28,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              '복용 기간이 종료된 약 알림',
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
              ...endedMedications.take(10).map((e) => _buildRow(e)),
              if (endedMedications.length > 10)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text(
                    '외 ${endedMedications.length - 10}건',
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
    final String name = (medication['name'] ?? medication['drug_name'] ?? '').toString();
    // 원본 end_date 우선 사용 (ISO 형식 문자열)
    final String? endDateStr = medication['end_date']?.toString();
    
    String formattedDate = '-';
    if (endDateStr != null && endDateStr.isNotEmpty && endDateStr != '-' && endDateStr != '무기한') {
      try {
        // ISO 형식으로 파싱 시도
        DateTime? date = DateTime.tryParse(endDateStr);
        
        if (date == null) {
          // 포맷팅된 날짜 형식 (YYYY년 MM월 DD일)에서 파싱 시도
          final formatted = endDateStr.replaceAll('년 ', '-').replaceAll('월 ', '-').replaceAll('일', '');
          final parts = formatted.split('-');
          if (parts.length == 3) {
            final year = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final day = int.tryParse(parts[2]);
            if (year != null && month != null && day != null) {
              date = DateTime(year, month, day);
            }
          }
        }
        
        if (date != null) {
          formattedDate = '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
        }
      } catch (_) {
        // 파싱 실패 시 원본 문자열 그대로 사용
        formattedDate = endDateStr;
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
              fontWeight: FontWeight.w300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '종료일: $formattedDate',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

