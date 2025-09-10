import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step3DosageWidget extends StatelessWidget {
  final int selectedFrequency;
  final List<String> dosageTimes;
  final List<String> mealRelations;
  final List<int> mealOffsets;
  final Function(int) onFrequencyChanged;
  final Function(int, String) onTimeChanged;
  final Function(int, String) onMealRelationChanged;
  final Function(int, int) onMealOffsetChanged;

  const Step3DosageWidget({
    super.key,
    required this.selectedFrequency,
    required this.dosageTimes,
    required this.mealRelations,
    required this.mealOffsets,
    required this.onFrequencyChanged,
    required this.onTimeChanged,
    required this.onMealRelationChanged,
    required this.onMealOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 정보를 설정해주세요',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.lg),
        
        _buildFrequencySelector(),
        SizedBox(height: AppSizes.lg),
        
        _buildDosageTimesList(),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '하루 복용 횟수',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        Row(
          children: List.generate(4, (index) {
            final frequency = index + 1;
            final isSelected = selectedFrequency == frequency;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => onFrequencyChanged(frequency),
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < 3 ? AppSizes.sm : 0,
                  ),
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '${frequency}회',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDosageTimesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 시간',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.sm),
        
        ...List.generate(selectedFrequency, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTimePickerButton(index),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  flex: 2,
                  child: _buildMealRelationDropdown(index),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  flex: 1,
                  child: _buildMealOffsetDropdown(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimePickerButton(int index) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
              DateFormat('HH:mm').parse(dosageTimes[index]),
            ),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onTimeChanged(index, picked.format(context));
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.sm,
            horizontal: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            dosageTimes[index],
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealRelationDropdown(int index) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: mealRelations[index],
        icon: Icon(Icons.arrow_drop_down),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onMealRelationChanged(index, newValue);
          }
        },
        items: <String>['식전', '식후', '식중', '상관없음']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealOffsetDropdown(int index) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: mealOffsets[index],
        icon: Icon(Icons.arrow_drop_down),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        onChanged: (int? newValue) {
          if (newValue != null) {
            onMealOffsetChanged(index, newValue);
          }
        },
        items: <int>[0, 10, 20, 30, 40, 50, 60]
            .map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text('$value분'),
          );
        }).toList(),
      ),
    );
  }
}