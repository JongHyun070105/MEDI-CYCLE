import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/registration_progress_bar.dart';
import '../widgets/registration_step_content.dart';

class MedicationRegistrationScreen extends ConsumerStatefulWidget {
  const MedicationRegistrationScreen({super.key});

  @override
  ConsumerState<MedicationRegistrationScreen> createState() =>
      _MedicationRegistrationScreenState();
}

class _MedicationRegistrationScreenState
    extends ConsumerState<MedicationRegistrationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // 더미 데이터
  String _selectedInputMethod = '이미지 등록';
  int _selectedFrequency = 3;
  List<String> _dosageTimes = ['08:00', '12:00', '18:00'];
  List<String> _mealRelations = ['식후', '식후', '식후'];
  List<int> _mealOffsets = [30, 30, 30];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isIndefinite = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('약 등록'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 임시 저장
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('임시 저장되었습니다'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시
          RegistrationProgressBar(currentStep: _currentStep, totalSteps: 5),

          // 단계별 콘텐츠
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 1단계: 사진 업로드/직접 입력 선택
                RegistrationStepContent(
                  step: 1,
                  title: '약 정보를 입력해주세요',
                  subtitle: '사진을 올리거나 직접 입력할 수 있습니다',
                  child: _buildStep1Content(),
                ),

                // 2단계: 복용 횟수 설정
                RegistrationStepContent(
                  step: 2,
                  title: '하루 복용 횟수를 설정해주세요',
                  subtitle: '약을 하루에 몇 번 복용하시나요?',
                  child: _buildStep2Content(),
                ),

                // 3단계: 복용 시간 설정
                RegistrationStepContent(
                  step: 3,
                  title: '복용 시간을 설정해주세요',
                  subtitle: '각 복용 시간과 식전/식후 여부를 설정해주세요',
                  child: _buildStep3Content(),
                ),

                // 4단계: 복용 기간 설정
                RegistrationStepContent(
                  step: 4,
                  title: '복용 기간을 설정해주세요',
                  subtitle: '언제부터 언제까지 복용하시나요?',
                  child: _buildStep4Content(),
                ),

                // 5단계: 최종 확인
                RegistrationStepContent(
                  step: 5,
                  title: '등록 정보를 확인해주세요',
                  subtitle: '설정한 내용을 최종 확인해주세요',
                  child: _buildStep5Content(),
                ),
              ],
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStep1Content() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.md), // 간격 줄임
        // 입력 방식 선택 버튼
        Row(
          children: [
            Expanded(
              child: _buildSelectionButton(
                title: '이미지 등록',
                icon: Icons.camera_alt,
                isSelected: _selectedInputMethod == '이미지 등록',
                onTap: () {
                  setState(() {
                    _selectedInputMethod = '이미지 등록';
                  });
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildSelectionButton(
                title: '직접 입력',
                icon: Icons.edit,
                isSelected: _selectedInputMethod == '직접 입력',
                onTap: () {
                  setState(() {
                    _selectedInputMethod = '직접 입력';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.lg), // 간격 줄임
        // 선택된 방식에 따른 UI 표시
        if (_selectedInputMethod == '이미지 등록') ...[
          // 이미지 업로드 영역
          GestureDetector(
            onTap: _uploadImage,
            child: Container(
              width: double.infinity,
              height: 150, // 높이 줄임
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '처방전이나 약봉지를 촬영해주세요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'OCR로 약 정보를 자동 인식합니다',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // 직접 입력 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '약 정보를 직접 입력해주세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  decoration: InputDecoration(
                    labelText: '약 이름',
                    hintText: '예: 타이레놀, 아스피린',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    prefixIcon: const Icon(Icons.medication),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  decoration: InputDecoration(
                    labelText: '복용량',
                    hintText: '예: 500mg, 1정',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.lg),

        // 복용 횟수 선택
        Text(
          '하루에 몇 번 복용하시나요?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSizes.xl),

        // 복용 횟수 버튼들
        Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: List.generate(6, (index) {
            final frequency = index + 1;
            return _buildFrequencyButton(frequency);
          }),
        ),

        const SizedBox(height: AppSizes.xl),

        // 안내 메시지
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  '복용 횟수는 나중에 수정할 수 있습니다',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyButton(int frequency) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
          // 복용 횟수에 따라 시간 리스트 업데이트
          _dosageTimes = _generateDefaultTimes(frequency);
          _mealRelations = List.filled(frequency, '식후');
          _mealOffsets = List.filled(frequency, 30);
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _selectedFrequency == frequency
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: _selectedFrequency == frequency
                ? AppColors.primary
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$frequency',
              style: AppTextStyles.h3.copyWith(
                color: _selectedFrequency == frequency
                    ? Colors.white
                    : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '회',
              style: AppTextStyles.bodySmall.copyWith(
                color: _selectedFrequency == frequency
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Content() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.lg),

        // 복용 시간 설정 안내
        Text(
          '각 복용 시간과 식전/식후 여부를 설정해주세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.xl),

        // 복용 시간 리스트
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedFrequency,
          itemBuilder: (context, index) {
            return _buildDosageTimeItem(index + 1);
          },
        ),

        const SizedBox(height: AppSizes.lg),

        // 시간 추가 버튼
        OutlinedButton.icon(
          onPressed: () {
            // TODO: 복용 시간 추가 로직
          },
          icon: const Icon(Icons.add, color: AppColors.primary),
          label: Text(
            '복용 시간 추가',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageTimeItem(int timeIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 복용 시간 번호
          Text(
            '$timeIndex번째 복용',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // 시간 선택
          Row(
            children: [
              Expanded(
                child: _buildTimePickerButton(_dosageTimes[timeIndex - 1]),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(child: _buildMealRelationSelector(timeIndex - 1)),
            ],
          ),

          const SizedBox(height: AppSizes.sm),

          // 식전/식후 시간 설정
          Row(
            children: [
              Expanded(child: _buildOffsetSelector(timeIndex - 1)),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Container(), // 빈 공간
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(String time) {
    return GestureDetector(
      onTap: () {
        // TODO: 시간 선택 다이얼로그
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.sm),
            Text(
              time,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRelationSelector(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: _mealRelations[index],
        underline: Container(),
        items: ['식전', '식후', '상관없음'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: AppTextStyles.bodySmall),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _mealRelations[index] = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildOffsetSelector(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<int>(
        value: _mealOffsets[index],
        underline: Container(),
        items: [0, 15, 30, 45, 60].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(
              value == 0 ? '즉시' : '$value분',
              style: AppTextStyles.bodySmall,
            ),
          );
        }).toList(),
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              _mealOffsets[index] = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildStep4Content() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.lg),

        // 복용 기간 설정 안내
        Text(
          '복용 시작일과 종료일을 설정해주세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.xl),

        // 시작일 설정
        _buildDateSelector(
          title: '복용 시작일',
          date: _startDate,
          onDateChanged: (date) {
            setState(() {
              _startDate = date;
              // 시작일이 종료일보다 이후면 종료일을 시작일 다음날로 설정
              if (!_isIndefinite && _endDate.isBefore(_startDate)) {
                _endDate = _startDate.add(const Duration(days: 1));
              }
            });
          },
        ),

        const SizedBox(height: AppSizes.lg),

        // 무기한 복용 옵션
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _isIndefinite,
                onChanged: (value) {
                  setState(() {
                    _isIndefinite = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '무기한 복용',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '상비약이나 장기 복용 약물인 경우',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.lg),

        // 종료일 설정 (무기한이 아닌 경우)
        if (!_isIndefinite)
          _buildDateSelector(
            title: '복용 종료일',
            date: _endDate,
            onDateChanged: (date) {
              setState(() {
                // 종료일이 시작일보다 이전이면 시작일 다음날로 설정
                if (date.isBefore(_startDate)) {
                  _endDate = _startDate.add(const Duration(days: 1));
                } else {
                  _endDate = date;
                }
              });
            },
          ),

        const SizedBox(height: AppSizes.lg),

        // 총 복용 기간 표시
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Text(
                _isIndefinite
                    ? '무기한 복용'
                    : '총 ${_endDate.difference(_startDate).inDays + 1}일간 복용예정',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime date,
    required Function(DateTime) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: () async {
            DateTime firstDate = DateTime.now();
            DateTime lastDate = DateTime.now().add(const Duration(days: 365));

            // 종료일 선택 시 시작일 이후로만 선택 가능
            if (title == '복용 종료일') {
              firstDate = _startDate;
            }

            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (selectedDate != null) {
              onDateChanged(selectedDate);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${date.year}년 ${date.month}월 ${date.day}일',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep5Content() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.lg),

        // 최종 확인 안내
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  '설정한 내용을 확인하고 등록을 완료해주세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.xl),

        // 등록 정보 요약
        _buildSummaryCard(
          title: '약품 정보',
          items: ['약품명: 아스피린', '제조사: 바이엘', '성분: 아세틸살리실산'],
        ),

        const SizedBox(height: AppSizes.md),

        _buildSummaryCard(
          title: '복용 정보',
          items: [
            '하루 복용 횟수: $_selectedFrequency회',
            '복용 시간: ${_dosageTimes.join(', ')}',
            '식전/식후: ${_mealRelations.first} ${_mealOffsets.first}분',
          ],
        ),

        const SizedBox(height: AppSizes.md),

        _buildSummaryCard(
          title: '복용 기간',
          items: [
            '시작일: ${_startDate.year}년 ${_startDate.month}월 ${_startDate.day}일',
            if (!_isIndefinite)
              '종료일: ${_endDate.year}년 ${_endDate.month}월 ${_endDate.day}일',
            _isIndefinite
                ? '복용 기간: 무기한'
                : '총 복용 기간: ${_endDate.difference(_startDate).inDays + 1}일',
          ],
        ),

        const SizedBox(height: AppSizes.xl),

        // 주의사항
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    '주의사항',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '• 복용 시간을 정확히 지켜주세요\n• 부작용이 나타나면 즉시 복용을 중단하고 의료진과 상담하세요\n• 다른 약과 함께 복용 시 의사와 상담하세요',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.xs),
              child: Text(
                '• $item',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.xl,
        AppSizes.md,
        AppSizes.xxl,
      ), // 하단 패딩을 더 크게 늘려서 버튼을 더 위로 올림
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  '이전',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSizes.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 4 ? _nextStep : _completeRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                _currentStep < 4 ? '다음' : '등록 완료',
                style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadImage() {
    // TODO: 실제 이미지 업로드 및 OCR 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 업로드'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 64, color: AppColors.primary),
            SizedBox(height: AppSizes.md),
            Text('이미지 업로드 기능은 개발 중입니다.\n현재는 직접 입력을 사용해주세요.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _completeRegistration() {
    // TODO: 등록 완료 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('약 등록이 완료되었습니다!'),
        backgroundColor: AppColors.primary,
      ),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  List<String> _generateDefaultTimes(int frequency) {
    switch (frequency) {
      case 1:
        return ['12:00'];
      case 2:
        return ['08:00', '20:00'];
      case 3:
        return ['08:00', '12:00', '18:00'];
      case 4:
        return ['06:00', '12:00', '18:00', '22:00'];
      case 5:
        return ['06:00', '10:00', '14:00', '18:00', '22:00'];
      case 6:
        return ['06:00', '09:00', '12:00', '15:00', '18:00', '21:00'];
      default:
        return ['12:00'];
    }
  }
}
