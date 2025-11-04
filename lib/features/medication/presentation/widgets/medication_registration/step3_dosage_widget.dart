import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';

class Step3DosageWidget extends StatefulWidget {
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
  State<Step3DosageWidget> createState() => _Step3DosageWidgetState();
}

class _Step3DosageWidgetState extends State<Step3DosageWidget> {
  bool _isCustomInput = false;
  final TextEditingController _customFrequencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 선택된 횟수가 1, 2, 3이 아니면 직접 입력 모드
    if (widget.selectedFrequency > 3) {
      _isCustomInput = true;
      _customFrequencyController.text = widget.selectedFrequency.toString();
    }
  }

  @override
  void dispose() {
    _customFrequencyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Step3DosageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 선택된 횟수가 1, 2, 3이 아니면 직접 입력 모드
    if (widget.selectedFrequency > 3) {
      if (!_isCustomInput) {
        setState(() {
          _isCustomInput = true;
          _customFrequencyController.text = widget.selectedFrequency.toString();
        });
      }
    } else if (_isCustomInput && widget.selectedFrequency <= 3) {
      setState(() {
        _isCustomInput = false;
        _customFrequencyController.clear();
      });
    }
  }

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
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSizes.sm),
        Row(
          children: [
            // 1회, 2회, 3회 버튼
            ...List.generate(3, (index) {
              final frequency = index + 1;
              final isSelected = !_isCustomInput && widget.selectedFrequency == frequency;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCustomInput = false;
                      _customFrequencyController.clear();
                    });
                    widget.onFrequencyChanged(frequency);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: AppSizes.sm),
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '$frequency회',
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
            // 직접 입력 버튼
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCustomInput = true;
                    if (widget.selectedFrequency > 3) {
                      _customFrequencyController.text = widget.selectedFrequency.toString();
                    } else {
                      _customFrequencyController.clear();
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  decoration: BoxDecoration(
                    color: _isCustomInput ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: _isCustomInput ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '직접 입력',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _isCustomInput ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 직접 입력 필드
        if (_isCustomInput) ...[
          SizedBox(height: AppSizes.md),
          TextField(
            controller: _customFrequencyController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3), // 최대 20회까지 (3자리로 변경)
            ],
            decoration: InputDecoration(
              hintText: '복용 횟수를 입력하세요 (최대 20회)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
            ),
            onSubmitted: (value) {
              if (value.isEmpty) return;
              final int? frequency = int.tryParse(value);
              if (frequency != null && frequency > 0 && frequency <= 20) {
                widget.onFrequencyChanged(frequency);
              }
            },
            onEditingComplete: () {
              final value = _customFrequencyController.text;
              if (value.isEmpty) return;
              final int? frequency = int.tryParse(value);
              if (frequency != null && frequency > 0 && frequency <= 20) {
                widget.onFrequencyChanged(frequency);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDosageTimesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복용 시간',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSizes.sm),

        ...List.generate(widget.selectedFrequency, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildTimePickerButton(index)),
                SizedBox(width: AppSizes.sm),
                Expanded(flex: 2, child: _buildMealRelationDropdown(index)),
                SizedBox(width: AppSizes.sm),
                Expanded(flex: 1, child: _buildMealOffsetDropdown(index)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimePickerButton(int index) {
    // 인덱스 범위 체크
    if (index >= widget.dosageTimes.length) {
      return Container(
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
          '00:00',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          final currentTime = DateFormat('HH:mm').parse(widget.dosageTimes[index]);
          final now = DateTime.now();
          final initialDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            currentTime.hour,
            currentTime.minute,
          );

          DateTime selectedDateTime = initialDateTime;
          showCupertinoModalPopup(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
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
                                style: TextStyle(color: CupertinoColors.systemRed),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoButton(
                              child: const Text('확인'),
                              onPressed: () {
                                final formattedTime =
                                    '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}';
                                widget.onTimeChanged(index, formattedTime);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: CupertinoDatePicker(
                            initialDateTime: initialDateTime,
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime dateTime) {
                              selectedDateTime = dateTime;
                              setModalState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
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
            widget.dosageTimes[index],
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
    // 인덱스 범위 체크
    if (index >= widget.mealRelations.length) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: '상관없음',
          icon: Icon(Icons.arrow_drop_down),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          onChanged: null, // 비활성화
          items: <String>['상관없음'].map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            },
          ).toList(),
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: widget.mealRelations[index],
        icon: Icon(Icons.arrow_drop_down),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        onChanged: (String? newValue) {
          if (newValue != null) {
            widget.onMealRelationChanged(index, newValue);
          }
        },
        items: <String>['식전', '식후', '식중', '상관없음'].map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          },
        ).toList(),
      ),
    );
  }

  Widget _buildMealOffsetDropdown(int index) {
    // 인덱스 범위 체크
    if (index >= widget.mealOffsets.length) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: 0,
          icon: Icon(Icons.arrow_drop_down),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          onChanged: null, // 비활성화
          items: <int>[0].map<DropdownMenuItem<int>>((
            int value,
          ) {
            return DropdownMenuItem<int>(value: value, child: Text('$value분'));
          }).toList(),
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: widget.mealOffsets[index],
        icon: Icon(Icons.arrow_drop_down),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        onChanged: (int? newValue) {
          if (newValue != null) {
            widget.onMealOffsetChanged(index, newValue);
          }
        },
        items: <int>[0, 10, 20, 30, 40, 50, 60].map<DropdownMenuItem<int>>((
          int value,
        ) {
          return DropdownMenuItem<int>(value: value, child: Text('$value분'));
        }).toList(),
      ),
    );
  }
}
