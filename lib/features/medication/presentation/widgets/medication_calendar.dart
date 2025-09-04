import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class MedicationCalendar extends StatelessWidget {
  const MedicationCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '복용 캘린더',
                style: AppTextStyles.h6,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  // TODO: 전체 캘린더 화면으로 이동
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.md),
          
          // 간단한 주간 뷰
          _buildWeekView(),
          
          const SizedBox(height: AppSizes.md),
          
          // 오늘의 복용 일정 요약
          _buildTodaySummary(),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.subtract(Duration(days: now.weekday - 1 - index));
      return date;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((date) {
        final isToday = date.day == now.day;
        final hasMedication = _hasMedicationOnDate(date);
        
        return _DayIndicator(
          date: date,
          isToday: isToday,
          hasMedication: hasMedication,
        );
      }).toList(),
    );
  }

  Widget _buildTodaySummary() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.today,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 복용 일정',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '아침: 2개, 점심: 1개, 저녁: 2개',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
        ],
      ),
    );
  }

  bool _hasMedicationOnDate(DateTime date) {
    // TODO: 실제 데이터에서 해당 날짜에 약물이 있는지 확인
    return date.weekday % 2 == 0; // 임시 로직
  }
}

class _DayIndicator extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool hasMedication;

  const _DayIndicator({
    required this.date,
    required this.isToday,
    required this.hasMedication,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _getDayName(date.weekday),
          style: AppTextStyles.caption.copyWith(
            color: isToday ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday 
                ? AppColors.primary 
                : hasMedication 
                    ? AppColors.primaryLight 
                    : AppColors.borderLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            border: isToday 
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isToday 
                    ? Colors.white 
                    : hasMedication 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
        if (hasMedication)
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }
}
