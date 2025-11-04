import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step4PeriodWidget extends StatefulWidget {
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
  State<Step4PeriodWidget> createState() => _Step4PeriodWidgetState();
}

class _Step4PeriodWidgetState extends State<Step4PeriodWidget> {
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

        if (!widget.isIndefinite) _buildEndDateSelector(context),
      ],
    );
  }

  Widget _buildStartDateSelector(BuildContext context) {
    final DateTime minDate = DateTime(2025, 1, 1);
    final DateTime maxDate = DateTime(2030, 12, 31);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 시작일',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () {
            DateTime selectedDate = widget.startDate;
            showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) => Container(
                height: 250,
                padding: const EdgeInsets.only(top: 6.0),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: CupertinoColors.systemBackground.resolveFrom(context),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child: const Text('확인'),
                            onPressed: () {
                              widget.onStartDateChanged(selectedDate);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          initialDateTime: widget.startDate,
                          minimumDate: minDate,
                          maximumDate: maxDate,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (DateTime newDate) {
                            selectedDate = newDate;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
                  '${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}',
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
          value: widget.isIndefinite,
          onChanged: (value) => widget.onIndefiniteChanged(value ?? false),
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
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () {
            DateTime selectedDate = widget.endDate;
            showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) => Container(
                height: 250,
                padding: const EdgeInsets.only(top: 6.0),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: CupertinoColors.systemBackground.resolveFrom(context),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child: const Text('확인'),
                            onPressed: () {
                              widget.onEndDateChanged(selectedDate);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          initialDateTime: widget.endDate,
                          minimumDate: widget.startDate,
                          maximumDate: DateTime(2030, 12, 31),
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (DateTime newDate) {
                            selectedDate = newDate;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
                  '${widget.endDate.year}-${widget.endDate.month.toString().padLeft(2, '0')}-${widget.endDate.day.toString().padLeft(2, '0')}',
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
