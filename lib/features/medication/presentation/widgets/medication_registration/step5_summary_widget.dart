import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step5SummaryWidget extends StatelessWidget {
  final String drugName;
  final String manufacturer;
  final String ingredient;
  final int frequency;
  final List<String> dosageTimes;
  final List<String> mealRelations;
  final List<int> mealOffsets;
  final DateTime startDate;
  final DateTime endDate;
  final bool isIndefinite;

  const Step5SummaryWidget({
    super.key,
    required this.drugName,
    required this.manufacturer,
    required this.ingredient,
    required this.frequency,
    required this.dosageTimes,
    required this.mealRelations,
    required this.mealOffsets,
    required this.startDate,
    required this.endDate,
    required this.isIndefinite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '등록 정보를 확인해주세요',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.lg),

        // 등록 정보 요약
        _buildSummaryCard(
          title: '약품 정보',
          items: [
            '약품명: ${drugName.isEmpty ? '사용자 입력 약' : drugName}',
            '제조사: $manufacturer',
            '성분: $ingredient',
          ],
        ),

        SizedBox(height: AppSizes.md),

        _buildSummaryCard(
          title: '복용 정보',
          items: [
            '하루 복용 횟수: $frequency회',
            '복용 시간: ${dosageTimes.join(', ')}',
            '식전/식후: ${mealRelations.join(', ')} ${mealOffsets.join(', ')}분',
          ],
        ),

        SizedBox(height: AppSizes.md),

        _buildSummaryCard(
          title: '복용 기간',
          items: [
            '시작일: ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
            '종료일: ${isIndefinite ? '무기한' : '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}'}',
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.xs),
              child: Text(
                item,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
