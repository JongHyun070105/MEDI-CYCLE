import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/profile_completion_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/address_input_field.dart';
import '../../../medication/presentation/screens/medication_home_screen.dart';
import '../../../../shared/services/address_search_service.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  String? _selectedGender;
  AddressResult? _selectedAddress;
  DateTime? _selectedBirthDate;

  final List<String> _genders = ['남성', '여성'];

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _handleCompleteProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('성별을 선택해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('생년월일을 선택해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedAddress == null && _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('주소를 입력해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final profileController = ref.read(
        profileCompletionControllerProvider.notifier,
      );
      final now = DateTime.now();
      final age = now.year - _selectedBirthDate!.year;
      await profileController.completeProfile(
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
        address: _selectedAddress?.roadAddr ?? _addressController.text.trim(),
        detailAddress: _detailAddressController.text.trim(),
      );

      final profileState = ref.read(profileCompletionControllerProvider);

      if (profileState.isCompleted && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MedicationHomeScreen()),
          (route) => false,
        );
      } else if (profileState.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.errorMessage ?? '프로필 완성 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleSkip() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MedicationHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileCompletionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 완성'),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목 및 설명
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.md),
                      Text(
                        '프로필을 완성해주세요',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'AI 기능을 위해 추가 정보가 필요합니다',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // 프로필 완성 폼
                Card(
                  elevation: AppSizes.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 생년월일 선택
                        Text(
                          '생년월일',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedBirthDate ?? DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedBirthDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.cake_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(
                                    _selectedBirthDate != null
                                        ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                                        : '생년월일을 선택해주세요',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: _selectedBirthDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // 성별 선택
                        Text(
                          '성별',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: _genders.map((gender) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSizes.sm,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = gender;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSizes.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedGender == gender
                                          ? AppColors.primary
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: _selectedGender == gender
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      gender,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: _selectedGender == gender
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: _selectedGender == gender
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // 주소 입력
                        AddressInputField(
                          controller: _addressController,
                          labelText: '주소',
                          hintText: '주소를 검색해주세요',
                          onAddressSelected: (address) {
                            setState(() {
                              _selectedAddress = address;
                            });
                          },
                          validator: (value) {
                            if (_selectedAddress == null &&
                                (value == null || value.isEmpty)) {
                              return '주소를 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // 상세주소 입력 (선택사항)
                        CustomTextField(
                          controller: _detailAddressController,
                          labelText: '상세주소 (선택사항)',
                          hintText: '상세주소를 입력해주세요',
                          prefixIcon: Icons.home_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // 완성 버튼
                CustomButton(
                  text: '프로필 완성',
                  onPressed: profileState.isLoading
                      ? null
                      : _handleCompleteProfile,
                  isLoading: profileState.isLoading,
                ),

                const SizedBox(height: AppSizes.lg),

                // 건너뛰기 버튼
                GestureDetector(
                  onTap: _handleSkip,
                  child: Text(
                    '나중에 설정하기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
