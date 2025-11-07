import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final bool isTaken;
  final VoidCallback? onTap;
  final VoidCallback? onTake;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.isTaken,
    this.onTap,
    this.onTake,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // 약물 아이콘
              LayoutBuilder(
                builder: (context, constraints) {
                  final double iconSize = (MediaQuery.of(context).size.width * 0.12).clamp(40.0, 56.0);
                  return Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isTaken ? AppColors.successLight : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(
                      isTaken ? Icons.check : Icons.medication,
                      color: isTaken ? AppColors.success : AppColors.primary,
                      size: iconSize * 0.5,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: AppSizes.md),
              
              // 약물 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '$dosage • $time',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 복용 상태 및 버튼
              Column(
                children: [
                  if (isTaken)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        '복용완료',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        '복용예정',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppSizes.xs),
                  
                  if (!isTaken && onTake != null)
                    ElevatedButton(
                      onPressed: onTake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 32),
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        '복용',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
