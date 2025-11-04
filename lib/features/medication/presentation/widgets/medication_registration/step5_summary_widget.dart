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
            ..._buildMealRelationItems(),
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

        SizedBox(height: AppSizes.xl),

        // 주의사항
        _buildWarningCard(),
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
          ...items.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
                child: Text(
                  item,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF616161), // 진한 회색
                    fontWeight: FontWeight.w400, // 폰트 웨이트 줄임
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<String> _buildMealRelationItems() {
    // 모든 복용 시간이 동일한 식전/식후와 간격을 가지는지 확인
    bool allSame = true;
    if (mealRelations.isNotEmpty && mealOffsets.isNotEmpty) {
      final firstMeal = mealRelations[0];
      final firstOffset = mealOffsets[0];
      for (int i = 1; i < mealRelations.length; i++) {
        if (mealRelations[i] != firstMeal || mealOffsets[i] != firstOffset) {
          allSame = false;
          break;
        }
      }
      
      // 모두 동일하면 간단히 표시
      if (allSame && mealRelations.isNotEmpty) {
        final mealText = firstMeal.isEmpty ? '상관없음' : firstMeal;
        final offsetText = firstOffset > 0 ? '$firstOffset분' : '';
        if (offsetText.isNotEmpty) {
          return ['식전/식후: $mealText $offsetText'];
        } else {
          return ['식전/식후: $mealText'];
        }
      }
    }
    
    // 각 복용 시간별로 표시
    List<String> items = [];
    for (int i = 0; i < dosageTimes.length && i < mealRelations.length && i < mealOffsets.length; i++) {
      final mealText = mealRelations[i].isEmpty ? '상관없음' : mealRelations[i];
      final offsetText = mealOffsets[i] > 0 ? ' ${mealOffsets[i]}분' : '';
      items.add('${dosageTimes[i]}: $mealText$offsetText');
    }
    
    return items.isEmpty ? ['식전/식후: 정보 없음'] : items;
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // 연한 오렌지 배경
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3), // 오렌지 테두리
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '주의사항',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          _buildWarningItem('복용 시간을 정확히 지켜주세요'),
          _buildWarningItem('부작용이 나타나면 즉시 복용을 중단하고 의료진과 상담하세요'),
          _buildWarningItem('다른 약과 함께 복용 시 의사와 상담하세요'),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
