import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/profile_completion_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/address_input_field.dart';
import '../../../../shared/services/address_search_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  String? _selectedGender;
  AddressResult? _selectedAddress;
  DateTime? _selectedBirthDate;

  final List<String> _genders = ['남성', '여성'];

  @override
  void initState() {
    super.initState();
    // 기존 사용자 정보로 초기화 (실제로는 API에서 가져와야 함)
    _nameController.text = '사용자';
    _emailController.text = 'user@example.com';
    _selectedGender = '남성';
    _selectedBirthDate = DateTime(1990);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 수정되었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      } else if (profileState.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.errorMessage ?? '프로필 수정 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileCompletionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: Colors.transparent,
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
                // 제목
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        '프로필 수정',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        '개인정보를 수정할 수 있습니다',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // 프로필 수정 폼
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
                        // 이름 입력
                        CustomTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '이름을 입력해주세요',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // 이메일 입력
                        CustomTextField(
                          controller: _emailController,
                          labelText: '이메일',
                          hintText: '이메일을 입력해주세요',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9@._-]'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return '올바른 이메일 형식을 입력해주세요';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.lg),

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

                // 저장 버튼
                CustomButton(
                  text: '프로필 저장',
                  onPressed: profileState.isLoading ? null : _handleSaveProfile,
                  isLoading: profileState.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
