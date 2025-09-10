import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step1InputMethodWidget extends StatelessWidget {
  final String selectedInputMethod;
  final Function(String) onInputMethodChanged;

  const Step1InputMethodWidget({
    super.key,
    required this.selectedInputMethod,
    required this.onInputMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '약 등록 방법을 선택해주세요',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.lg),
        
        _buildInputMethodOption(
          '이미지 등록',
          '약품 사진을 촬영하여 등록',
          Icons.camera_alt,
        ),
        SizedBox(height: AppSizes.md),
        
        _buildInputMethodOption(
          '직접 입력',
          '약품명을 직접 입력하여 등록',
          Icons.edit,
        ),
      ],
    );
  }

  Widget _buildInputMethodOption(String title, String subtitle, IconData icon) {
    final isSelected = selectedInputMethod == title;
    
    return GestureDetector(
      onTap: () => onInputMethodChanged(title),
      child: Container(
        padding: EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: AppSizes.iconMd,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: AppSizes.iconMd,
              ),
          ],
        ),
      ),
    );
  }
}
