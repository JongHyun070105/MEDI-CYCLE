import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_controller.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    @Default(false) bool hasError,
    String? errorMessage,
    String? userEmail,
    String? userName,
  }) = _AuthState;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 실제 구현에서는 API 호출을 통해 로그인 처리
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      // 임시 로그인 로직 (실제로는 서버에서 인증)
      if (email.isNotEmpty && password.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: email,
          userName: email.split('@')[0], // 임시로 이메일에서 이름 추출
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: '이메일과 비밀번호를 입력해주세요.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: '로그인 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 실제 구현에서는 API 호출을 통해 회원가입 처리
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      // 임시 회원가입 로직 (실제로는 서버에서 처리)
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: email,
          userName: name,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: '모든 필드를 입력해주세요.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: '회원가입 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      isAuthenticated: false,
      userEmail: null,
      userName: null,
      hasError: false,
      errorMessage: null,
    );
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 실제 구현에서는 API 호출을 통해 비밀번호 재설정 처리
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      state = state.copyWith(isLoading: false, hasError: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: '비밀번호 재설정 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
