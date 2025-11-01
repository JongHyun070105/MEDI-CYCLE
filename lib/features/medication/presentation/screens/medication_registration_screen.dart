import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/services/medication_service.dart';
import '../../../../shared/services/api_service.dart';
import '../widgets/registration_progress_bar.dart';
import '../widgets/registration_step_content.dart';
import '../widgets/medication_registration/step1_input_method_widget.dart';
import '../widgets/medication_registration/step2_drug_name_widget.dart';
import '../widgets/medication_registration/step3_dosage_widget.dart';
import '../widgets/medication_registration/step4_period_widget.dart';
import '../widgets/medication_registration/step5_summary_widget.dart';

class MedicationRegistrationScreen extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onMedicationAdded;

  const MedicationRegistrationScreen({super.key, this.onMedicationAdded});

  @override
  ConsumerState<MedicationRegistrationScreen> createState() =>
      _MedicationRegistrationScreenState();
}

class _MedicationRegistrationScreenState
    extends ConsumerState<MedicationRegistrationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // 약 등록 데이터
  String _selectedInputMethod = '이미지 등록';
  int _selectedFrequency = 3;
  List<String> _dosageTimes = ['08:00', '12:00', '18:00'];
  List<String> _mealRelations = ['식후', '식후', '식후'];
  List<int> _mealOffsets = [30, 30, 30];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isIndefinite = false;
  final TextEditingController _drugNameController = TextEditingController();

  // 약 상세 정보
  String _selectedDrugManufacturer = '-';
  String _selectedDrugIngredient = '-';

  @override
  void dispose() {
    _pageController.dispose();
    _drugNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('약 등록'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 진행률 표시
          RegistrationProgressBar(currentStep: _currentStep, totalSteps: 5),

          // 단계별 내용
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              clipBehavior: Clip.none,
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ],
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return RegistrationStepContent(
      step: 1,
      title: '입력 방법 선택',
      subtitle: '약품을 등록할 방법을 선택해주세요',
      child: Step1InputMethodWidget(
        selectedInputMethod: _selectedInputMethod,
        onInputMethodChanged: (method) {
          setState(() {
            _selectedInputMethod = method;
          });
        },
      ),
    );
  }

  Widget _buildStep2() {
    return RegistrationStepContent(
      step: 2,
      title: '약품명 입력',
      subtitle: '등록할 약품의 이름을 입력해주세요',
      child: Step2DrugNameWidget(
        drugNameController: _drugNameController,
        onDrugDetailsLoaded: (details) {
          final parts = details.split('|');
          setState(() {
            _selectedDrugManufacturer = parts.isNotEmpty ? parts[0] : '-';
            _selectedDrugIngredient = parts.length > 1 ? parts[1] : '-';
          });
        },
      ),
    );
  }

  Widget _buildStep3() {
    return RegistrationStepContent(
      step: 3,
      title: '복용 정보 설정',
      subtitle: '복용 빈도와 시간을 설정해주세요',
      child: Step3DosageWidget(
        selectedFrequency: _selectedFrequency,
        dosageTimes: _dosageTimes,
        mealRelations: _mealRelations,
        mealOffsets: _mealOffsets,
        onFrequencyChanged: _onFrequencyChanged,
        onTimeChanged: _onTimeChanged,
        onMealRelationChanged: _onMealRelationChanged,
        onMealOffsetChanged: _onMealOffsetChanged,
      ),
    );
  }

  Widget _buildStep4() {
    return RegistrationStepContent(
      step: 4,
      title: '복용 기간 설정',
      subtitle: '약품을 복용할 기간을 설정해주세요',
      child: Step4PeriodWidget(
        startDate: _startDate,
        endDate: _endDate,
        isIndefinite: _isIndefinite,
        onStartDateChanged: (date) {
          setState(() {
            _startDate = date;
          });
        },
        onEndDateChanged: (date) {
          setState(() {
            _endDate = date;
          });
        },
        onIndefiniteChanged: (isIndefinite) {
          setState(() {
            _isIndefinite = isIndefinite;
          });
        },
      ),
    );
  }

  Widget _buildStep5() {
    return RegistrationStepContent(
      step: 5,
      title: '등록 정보 확인',
      subtitle: '입력한 정보를 확인하고 등록을 완료해주세요',
      child: Step5SummaryWidget(
        drugName: _drugNameController.text.trim(),
        manufacturer: _selectedDrugManufacturer,
        ingredient: _selectedDrugIngredient,
        frequency: _selectedFrequency,
        dosageTimes: _dosageTimes,
        mealRelations: _mealRelations,
        mealOffsets: _mealOffsets,
        startDate: _startDate,
        endDate: _endDate,
        isIndefinite: _isIndefinite,
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('이전'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSizes.md),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _currentStep == 4 ? _completeRegistration : _nextStep,
              child: Text(_currentStep == 4 ? '등록 완료' : '다음'),
            ),
          ),
          if (_currentStep == 4) ...[
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: OutlinedButton(
                onPressed: _addAnotherMedication,
                child: const Text('다른 약 추가하기'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onFrequencyChanged(int frequency) {
    setState(() {
      _selectedFrequency = frequency;
      _dosageTimes = _generateDefaultTimes(frequency);
      _mealRelations = List.filled(frequency, '식후');
      _mealOffsets = List.filled(frequency, 30);
    });
  }

  void _onTimeChanged(int index, String time) {
    setState(() {
      _dosageTimes[index] = time;
    });
  }

  void _onMealRelationChanged(int index, String relation) {
    setState(() {
      _mealRelations[index] = relation;
    });
  }

  void _onMealOffsetChanged(int index, int offset) {
    setState(() {
      _mealOffsets[index] = offset;
    });
  }

  List<String> _generateDefaultTimes(int frequency) {
    switch (frequency) {
      case 1:
        return ['12:00'];
      case 2:
        return ['09:00', '21:00'];
      case 3:
        return ['08:00', '12:00', '18:00'];
      case 4:
        return ['08:00', '12:00', '18:00', '22:00'];
      default:
        return ['12:00'];
    }
  }

  Future<bool> _completeRegistration({bool shouldCloseScreen = true}) async {
    try {
      // 서버 형식으로 데이터 변환
      final request = MedicationService.convertToServerFormat(
        drugName: _drugNameController.text.trim().isEmpty
            ? '사용자 입력 약'
            : _drugNameController.text.trim(),
        frequency: '하루 $_selectedFrequency회',
        dosageTimes: _dosageTimes.map((timeStr) {
          final parts = timeStr.split(':');
          final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12;
          final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
          return DateTime.now().copyWith(
            hour: hour.clamp(0, 23),
            minute: minute.clamp(0, 59),
          );
        }).toList(),
        mealRelations: _mealRelations,
        mealOffsets: _mealOffsets,
        startDate: _startDate,
        endDate: _isIndefinite ? null : _endDate,
        isIndefinite: _isIndefinite,
        manufacturer: _selectedDrugManufacturer,
        ingredient: _selectedDrugIngredient,
      );

      // 서버에 약 등록 요청
      final medication = await medicationService.createMedication(request);

      // 로컬 형식으로 변환하여 UI에 표시
      final registered = {
        'id': medication.id,
        'name': medication.name,
        'manufacturer': _selectedDrugManufacturer,
        'frequency': '하루 $_selectedFrequency회',
        'times': List<String>.from(_dosageTimes),
        'startDate':
            '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
        'endDate': _isIndefinite
            ? '무기한'
            : '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('약 등록이 완료되었습니다!'),
            backgroundColor: AppColors.primary,
          ),
        );

        if (shouldCloseScreen) {
          Navigator.of(context).pop(registered);
        } else {
          _addMedicationToList(registered);
        }
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : '약 등록 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  void _addMedicationToList(Map<String, dynamic> medication) {
    if (widget.onMedicationAdded != null) {
      widget.onMedicationAdded!(medication);
    }
  }

  void _addAnotherMedication() async {
    // 현재 약을 먼저 등록 (화면은 닫지 않음)
    final registered = await _completeRegistration(shouldCloseScreen: false);

    if (registered) {
      // 등록 성공 후 폼 초기화
      _drugNameController.clear();
      _selectedFrequency = 1;
      _dosageTimes = _generateDefaultTimes(_selectedFrequency);
      _mealRelations = List.filled(_selectedFrequency, '상관없음');
      _mealOffsets = List.filled(_selectedFrequency, 0);
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));

      // 약 상세 정보 초기화
      _selectedDrugManufacturer = '-';
      _selectedDrugIngredient = '-';

      // 첫 번째 단계로 이동
      setState(() {
        _currentStep = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
