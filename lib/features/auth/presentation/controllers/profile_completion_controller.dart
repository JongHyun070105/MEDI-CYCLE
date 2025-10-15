import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/services/auth_service.dart';

part 'profile_completion_controller.freezed.dart';

@freezed
class ProfileCompletionState with _$ProfileCompletionState {
  const factory ProfileCompletionState({
    @Default(false) bool isLoading,
    @Default(false) bool isCompleted,
    @Default(false) bool hasError,
    String? errorMessage,
    DateTime? birthDate,
    String? gender,
    String? address,
    String? detailAddress,
  }) = _ProfileCompletionState;
}

class ProfileCompletionController
    extends StateNotifier<ProfileCompletionState> {
  final AuthService _authService = authService;

  ProfileCompletionController() : super(const ProfileCompletionState());

  Future<void> completeProfile({
    required DateTime birthDate,
    required String gender,
    required String address,
    String? detailAddress,
  }) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 생년월일로부터 나이 계산 (현재는 사용하지 않음)
      // final now = DateTime.now();
      // final age = now.year - birthDate.year;

      // 프로필 정보 업데이트 (실제로는 서버 API 호출)
      // 현재는 로컬 상태만 업데이트
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        birthDate: birthDate,
        gender: gender,
        address: address,
        detailAddress: detailAddress,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: '프로필 완성 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const ProfileCompletionState();
  }
}

final profileCompletionControllerProvider =
    StateNotifierProvider<ProfileCompletionController, ProfileCompletionState>(
      (ref) => ProfileCompletionController(),
    );
