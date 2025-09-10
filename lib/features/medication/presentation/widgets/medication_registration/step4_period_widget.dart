import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step4PeriodWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isIndefinite;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(bool) onIndefiniteChanged;

  const Step4PeriodWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.isIndefinite,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onIndefiniteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 기간을 설정해주세요',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.lg),
        
        _buildStartDateSelector(context),
        SizedBox(height: AppSizes.lg),
        
        _buildIndefiniteToggle(),
        SizedBox(height: AppSizes.lg),
        
        if (!isIndefinite) _buildEndDateSelector(context),
      ],
    );
  }

  Widget _buildStartDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 시작일',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && picked != startDate) {
              onStartDateChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: AppSizes.iconSm,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndefiniteToggle() {
    return Row(
      children: [
        Checkbox(
          value: isIndefinite,
          onChanged: (value) => onIndefiniteChanged(value ?? false),
          activeColor: AppColors.primary,
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            '무기한 복용',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 종료일',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: endDate,
              firstDate: startDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && picked != endDate) {
              onEndDateChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: AppSizes.iconSm,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
