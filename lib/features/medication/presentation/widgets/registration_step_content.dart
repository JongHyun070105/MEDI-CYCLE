import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_responsive.dart';

class RegistrationStepContent extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final Widget child;

  const RegistrationStepContent({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppResponsive.getCardPadding(context),
        right: AppResponsive.getCardPadding(context),
        top: AppResponsive.getCardPadding(context),
        bottom: AppSizes.xl + 100, // 하단 여백 추가 (FAB 높이 고려)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 단계별 아이콘과 제목
          Row(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double iconSize = (MediaQuery.of(context).size.width * 0.1).clamp(36.0, 48.0);
                  return Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(iconSize / 2),
                    ),
                    child: Icon(_getStepIcon(step), color: Colors.white, size: iconSize * 0.5),
                  );
                },
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // 단계별 콘텐츠
          child,
        ],
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.camera_alt;
      case 2:
        return Icons.repeat;
      case 3:
        return Icons.access_time;
      case 4:
        return Icons.calendar_today;
      case 5:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
