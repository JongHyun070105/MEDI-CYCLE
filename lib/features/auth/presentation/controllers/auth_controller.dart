import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/api_client.dart';

part 'auth_controller.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    @Default(false) bool hasError,
    String? errorMessage,
    User? user,
  }) = _AuthState;
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService = authService;

  AuthController() : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _authService.login(
        UserLoginRequest(email: email, password: password),
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is ApiException
            ? e.message
            : (e is Exception
                  ? e.toString().replaceFirst('Exception: ', '')
                  : '로그인에 실패했습니다. 다시 시도해주세요.'),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    int? age,
    String? address,
    String? gender,
  }) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      print('🔍 AuthController.register 시작');
      final response = await _authService.signup(
        UserSignupRequest(
          email: email,
          password: password,
          name: name,
          age: age,
          address: address,
          gender: gender,
        ),
      );

      print('🔍 AuthController.register 응답 받음: $response');
      print('🔍 AuthController.register user: ${response.user}');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        hasError: false,
        errorMessage: null,
      );

      print('🔍 AuthController.register 상태 업데이트 완료');
    } catch (e) {
      print('❌ AuthController.register 오류: $e');
      print('❌ AuthController.register 오류 타입: ${e.runtimeType}');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e is ApiException
            ? e.message
            : (e is Exception
                  ? e.toString().replaceFirst('Exception: ', '')
                  : '회원가입에 실패했습니다. 다시 시도해주세요.'),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      // 로그아웃 실패해도 로컬 상태는 초기화
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        hasError: false,
        errorMessage: null,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // TODO: 서버에 비밀번호 재설정 API가 구현되면 연동
      await Future.delayed(const Duration(seconds: 1)); // 임시 시뮬레이션

      state = state.copyWith(isLoading: false, hasError: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: '비밀번호 재설정 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 앱 시작 시 토큰 확인
  Future<void> checkAuthStatus() async {
    if (_authService.isLoggedIn) {
      try {
        final user = await _authService.getMe();
        state = state.copyWith(isAuthenticated: true, user: user);
      } catch (e) {
        // 토큰이 유효하지 않은 경우 로그아웃
        await logout();
      }
    }
  }

  /// 프로필 로드 (자동로그인 이후 사용자 정보 동기화)
  Future<bool> loadUserProfile({
    int? expectedUserId,
    String? expectedEmail,
  }) async {
    try {
      final user = await _authService.getMe();
      if ((expectedUserId != null && user.id != expectedUserId) ||
          (expectedEmail != null && user.email != expectedEmail)) {
        await _authService.logout();
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          hasError: true,
          errorMessage: '자동 로그인을 다시 진행해주세요.',
        );
        return false;
      }

      try {
        await ApiClient()
            .saveUserIdentity(userId: user.id, email: user.email);
      } catch (_) {}

      state = state.copyWith(isAuthenticated: true, user: user, hasError: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: '사용자 정보를 불러오지 못했습니다.',
      );
      return false;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
