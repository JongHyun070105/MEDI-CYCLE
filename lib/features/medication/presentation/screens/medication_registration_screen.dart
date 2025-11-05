import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/services/medication_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/models/medication_model.dart';
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
  bool _isSubmitting = false; // 약 등록 중복 방지 플래그

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

  // 약 서비스 인스턴스
  final MedicationService _medicationService = MedicationService();

  @override
  void dispose() {
    _pageController.dispose();
    _drugNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('약 등록'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
          body: Stack(
            children: [
              Column(
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

                  // 하단 버튼 공간 확보 (키보드 높이만큼)
                  SizedBox(height: 80),
                ],
              ),

              // 하단 버튼 고정
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomButtons(),
              ),
        ],
      ),
        ),

      ],
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
              onPressed: _isSubmitting
                  ? null
                  : (_currentStep == 4 ? _completeRegistration : _nextStep),
              child: Text(_currentStep == 4 ? '등록 완료' : '다음'),
            ),
          ),
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
      // 시간 순서대로 정렬 (mealRelations와 mealOffsets도 함께 재정렬)
      final List<Map<String, dynamic>> timeData = [];
      for (int i = 0; i < _dosageTimes.length; i++) {
        timeData.add({
          'time': _dosageTimes[i],
          'meal': _mealRelations[i],
          'offset': _mealOffsets[i],
        });
      }
      // 시간 순서대로 정렬
      timeData.sort((a, b) {
        final timeA = a['time'] as String;
        final timeB = b['time'] as String;
        final partsA = timeA.split(':');
        final partsB = timeB.split(':');
        final hourA = int.tryParse(partsA[0]) ?? 0;
        final minuteA = partsA.length > 1 ? (int.tryParse(partsA[1]) ?? 0) : 0;
        final hourB = int.tryParse(partsB[0]) ?? 0;
        final minuteB = partsB.length > 1 ? (int.tryParse(partsB[1]) ?? 0) : 0;
        if (hourA != hourB) {
          return hourA.compareTo(hourB);
        }
        return minuteA.compareTo(minuteB);
      });
      // 정렬된 데이터로 다시 할당
      _dosageTimes = timeData.map((e) => e['time'] as String).toList();
      _mealRelations = timeData.map((e) => e['meal'] as String).toList();
      _mealOffsets = timeData.map((e) => e['offset'] as int).toList();
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
    // 중복 제출 방지
    if (_isSubmitting) {
      return false;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final drugName = _drugNameController.text.trim().isEmpty
          ? '사용자 입력 약'
          : _drugNameController.text.trim();

      // 복용 시간 정렬 및 문자열로 변환
      final sortedTimes = List<String>.from(_dosageTimes)
        ..sort((a, b) {
          final partsA = a.split(':');
          final partsB = b.split(':');
          final hourA = int.tryParse(partsA[0]) ?? 0;
          final minuteA = partsA.length > 1 ? int.tryParse(partsA[1]) ?? 0 : 0;
          final hourB = int.tryParse(partsB[0]) ?? 0;
          final minuteB = partsB.length > 1 ? int.tryParse(partsB[1]) ?? 0 : 0;
          if (hourA != hourB) {
            return hourA.compareTo(hourB);
          }
          return minuteA.compareTo(minuteB);
        });

      // 기존 약 목록 확인
      final existingMedications = await _medicationService.getMedications();
      
      // 동일한 약 이름과 동일한 시간대를 가진 약이 있는지 확인
      final matchingMedications = existingMedications.where((med) {
        if (med.name != drugName) return false;
        
        // 약의 복용 시간 목록 가져오기
        final List<String> medTimes = [];
        if (med.time1 != null) {
          medTimes.add('${med.time1!.hour.toString().padLeft(2, '0')}:${med.time1!.minute.toString().padLeft(2, '0')}');
        }
        if (med.time2 != null) {
          medTimes.add('${med.time2!.hour.toString().padLeft(2, '0')}:${med.time2!.minute.toString().padLeft(2, '0')}');
        }
        if (med.time3 != null) {
          medTimes.add('${med.time3!.hour.toString().padLeft(2, '0')}:${med.time3!.minute.toString().padLeft(2, '0')}');
        }
        if (med.time4 != null) {
          medTimes.add('${med.time4!.hour.toString().padLeft(2, '0')}:${med.time4!.minute.toString().padLeft(2, '0')}');
        }
        if (med.time5 != null) {
          medTimes.add('${med.time5!.hour.toString().padLeft(2, '0')}:${med.time5!.minute.toString().padLeft(2, '0')}');
        }
        if (med.time6 != null) {
          medTimes.add('${med.time6!.hour.toString().padLeft(2, '0')}:${med.time6!.minute.toString().padLeft(2, '0')}');
        }
        
        // 시간 정렬
        medTimes.sort((a, b) {
          final partsA = a.split(':');
          final partsB = b.split(':');
          final hourA = int.tryParse(partsA[0]) ?? 0;
          final minuteA = partsA.length > 1 ? int.tryParse(partsA[1]) ?? 0 : 0;
          final hourB = int.tryParse(partsB[0]) ?? 0;
          final minuteB = partsB.length > 1 ? int.tryParse(partsB[1]) ?? 0 : 0;
          if (hourA != hourB) {
            return hourA.compareTo(hourB);
          }
          return minuteA.compareTo(minuteB);
        });
        
        // 약 이름과 시간대가 완전히 동일한지 확인
        if (medTimes.length != sortedTimes.length) return false;
        for (int i = 0; i < medTimes.length; i++) {
          if (medTimes[i] != sortedTimes[i]) return false;
        }
        return true;
      }).toList();

      // 동일한 약 이름과 동일한 시간대가 있는 경우 사용자에게 알림
      if (matchingMedications.isNotEmpty) {
        if (!mounted) {
          setState(() {
            _isSubmitting = false;
          });
          return false;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동일한 약과 복용 시간대로 이미 등록된 약이 있습니다.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        
        setState(() {
          _isSubmitting = false;
        });
        return false;
      }

      // 약 이름만 동일한 경우 업데이트 다이얼로그 표시
      final nameOnlyMatches = existingMedications.where(
        (med) => med.name == drugName,
      ).toList();

      if (nameOnlyMatches.isNotEmpty) {
        final existingMedication = nameOnlyMatches.first;
        final shouldUpdate = await _showUpdateDialog(existingMedication);
        
        // null이면 다이얼로그 취소 (등록 중단)
        if (shouldUpdate == null) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
          return false;
        }

        // 업데이트 선택 시 기존 약 업데이트
        if (shouldUpdate == true) {
          try {
            final updateRequest = MedicationUpdateRequest(
              name: drugName,
              dailyCount: _selectedFrequency,
              time1: _dosageTimes.isNotEmpty
                  ? Time(
                      hour: int.tryParse(_dosageTimes[0].split(':')[0]) ?? 12,
                      minute: _dosageTimes[0].split(':').length > 1
                          ? int.tryParse(_dosageTimes[0].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time2: _dosageTimes.length > 1
                  ? Time(
                      hour: int.tryParse(_dosageTimes[1].split(':')[0]) ?? 12,
                      minute: _dosageTimes[1].split(':').length > 1
                          ? int.tryParse(_dosageTimes[1].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time3: _dosageTimes.length > 2
                  ? Time(
                      hour: int.tryParse(_dosageTimes[2].split(':')[0]) ?? 12,
                      minute: _dosageTimes[2].split(':').length > 1
                          ? int.tryParse(_dosageTimes[2].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time4: _dosageTimes.length > 3
                  ? Time(
                      hour: int.tryParse(_dosageTimes[3].split(':')[0]) ?? 12,
                      minute: _dosageTimes[3].split(':').length > 1
                          ? int.tryParse(_dosageTimes[3].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time5: _dosageTimes.length > 4
                  ? Time(
                      hour: int.tryParse(_dosageTimes[4].split(':')[0]) ?? 12,
                      minute: _dosageTimes[4].split(':').length > 1
                          ? int.tryParse(_dosageTimes[4].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time6: _dosageTimes.length > 5
                  ? Time(
                      hour: int.tryParse(_dosageTimes[5].split(':')[0]) ?? 12,
                      minute: _dosageTimes[5].split(':').length > 1
                          ? int.tryParse(_dosageTimes[5].split(':')[1]) ?? 0
                          : 0,
                    )
                  : null,
              time1Meal: _mealRelations.isNotEmpty ? _mealRelations[0] : null,
              time2Meal: _mealRelations.length > 1 ? _mealRelations[1] : null,
              time3Meal: _mealRelations.length > 2 ? _mealRelations[2] : null,
              time4Meal: _mealRelations.length > 3 ? _mealRelations[3] : null,
              time5Meal: _mealRelations.length > 4 ? _mealRelations[4] : null,
              time6Meal: _mealRelations.length > 5 ? _mealRelations[5] : null,
              time1OffsetMin: _mealOffsets.isNotEmpty ? _mealOffsets[0] : null,
              time2OffsetMin: _mealOffsets.length > 1 ? _mealOffsets[1] : null,
              time3OffsetMin: _mealOffsets.length > 2 ? _mealOffsets[2] : null,
              time4OffsetMin: _mealOffsets.length > 3 ? _mealOffsets[3] : null,
              time5OffsetMin: _mealOffsets.length > 4 ? _mealOffsets[4] : null,
              time6OffsetMin: _mealOffsets.length > 5 ? _mealOffsets[5] : null,
              startDate: _startDate,
              endDate: _isIndefinite ? null : _endDate,
              isIndefinite: _isIndefinite,
            );

            // 기존 알림 취소
            try {
              await notificationService.cancelMedicationNotifications(
                existingMedication.id,
              );
            } catch (e) {
              debugPrint('알림 취소 실패: $e');
            }

            final medication = await _medicationService.updateMedication(
              existingMedication.id,
              updateRequest,
            );

            // 새로운 알림 스케줄링
            try {
              await notificationService.scheduleMedicationNotifications(medication);
            } catch (e) {
              debugPrint('알림 스케줄링 실패: $e');
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('약 정보가 업데이트되었습니다!'),
                  backgroundColor: AppColors.primary,
                ),
              );

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

              // 약 업데이트 시에도 콜백 호출
              _addMedicationToList(registered);

              if (shouldCloseScreen) {
                Navigator.of(context).pop(registered);
              }
            }
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }
            return true;
          } catch (e) {
            // 업데이트 실패 시 새로 등록 진행
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('약 업데이트에 실패했습니다. 새로 등록합니다.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            // catch 블록 밖으로 빠져나가서 새로 등록 진행
          }
        }
      }
    } catch (e) {
      // 동일한 약 체크 중 오류 발생 시 계속 진행
      debugPrint('약 중복 체크 중 오류: $e');
    }

    try {
      // 서버 형식으로 데이터 변환
      final request = MedicationService.convertToServerFormat(
        drugName: _drugNameController.text.trim().isEmpty
            ? '사용자 입력 약'
            : _drugNameController.text.trim(),
        frequency: '', // 빈 문자열로 전달 (내부에서 dailyCount 자동 계산됨)
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
      final medication = await _medicationService.createMedication(request);

      // 알림 스케줄링
      try {
        await notificationService.scheduleMedicationNotifications(medication);
      } catch (e) {
        debugPrint('알림 스케줄링 실패: $e');
      }

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

        // 약 등록 시에도 콜백 호출
        _addMedicationToList(registered);

        if (shouldCloseScreen) {
          Navigator.of(context).pop(registered);
        }
      }
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
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

  Future<bool?> _showUpdateDialog(Medication existingMedication) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('이미 등록된 약'),
        content: Text(
          '"${existingMedication.name}"라는 이름의 약이 이미 등록되어 있습니다.\n\n기존 약 정보를 업데이트하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('새로 등록'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('업데이트'),
          ),
        ],
      ),
    );
    return result;
  }

  void _addMedicationToList(Map<String, dynamic> medication) {
    if (widget.onMedicationAdded != null) {
      widget.onMedicationAdded!(medication);
    }
  }

}
