import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_completion_controller.freezed.dart';

@freezed
class ProfileCompletionState with _$ProfileCompletionState {
  const factory ProfileCompletionState({
    @Default(false) bool isLoading,
    @Default(false) bool isCompleted,
    @Default(false) bool hasError,
    String? errorMessage,
    int? age,
    String? gender,
    String? address,
  }) = _ProfileCompletionState;
}

class ProfileCompletionController
    extends StateNotifier<ProfileCompletionState> {
  ProfileCompletionController() : super(const ProfileCompletionState());

  Future<void> completeProfile({
    required int age,
    required String gender,
    required String address,
  }) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 실제 구현에서는 API 호출을 통해 프로필 정보 저장
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      // 프로필 정보 저장 로직
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        age: age,
        gender: gender,
        address: address,
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
