import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_responsive.dart';

class ExpiryAlertModal extends StatelessWidget {
  final List<Map<String, dynamic>> imminent; // 임박
  final List<Map<String, dynamic>> expired; // 만료
  final VoidCallback onGoDisposal;

  const ExpiryAlertModal({
    super.key,
    required this.imminent,
    required this.expired,
    required this.onGoDisposal,
  });

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = AppResponsive.getDialogWidth(context);
    final bool hasExpired = expired.isNotEmpty;
    final bool hasImminent = imminent.isNotEmpty;
    final Color primaryColor = hasExpired ? AppColors.error : AppColors.warning;
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
              '유효기간 알림',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
            color: AppColors.textSecondary,
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
              if (hasExpired) ...[
                Text(
                  '만료된 약',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                ...expired.take(5).map((e) => _buildRow(e, true)),
                if (expired.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      '외 ${expired.length - 5}건',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                if (hasImminent) const SizedBox(height: AppSizes.md),
              ],
              if (hasImminent) ...[
                Text(
                  '임박한 약',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                ...imminent.take(5).map((e) => _buildRow(e, false)),
                if (imminent.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      '외 ${imminent.length - 5}건',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
              if (imminent.isEmpty && expired.isEmpty)
                Text('표시할 항목이 없습니다.', style: AppTextStyles.bodySmall),
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
          child: const Text('확인'),
        ),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> e, bool expired) {
    final String name = (e['drug_name'] ?? '').toString();
    final String? expiryStr = e['expiry_date']?.toString();
    final Color rowColor = expired ? AppColors.error : AppColors.warning;
    
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
      child: Text(
        '$name · $formattedDate',
        style: AppTextStyles.bodyLarge.copyWith(
          color: rowColor,
          fontWeight: FontWeight.w300,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


