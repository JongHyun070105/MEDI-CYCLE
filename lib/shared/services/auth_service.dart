import '../models/user_model.dart';
import 'api_service.dart';
import 'api_client.dart';

class AuthService {
  final ApiService _apiService = apiService;

  /// 회원가입
  Future<AuthResponse> signup(UserSignupRequest request) async {
    try {
      // 1. 회원가입 요청
      await _apiService.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: request.toJson(),
      );

      // 2. 회원가입 성공 후 자동 로그인
      final loginResponse = await login(
        UserLoginRequest(email: request.email, password: request.password),
      );

      return loginResponse;
    } catch (e) {
      // Pass through ApiException messages as-is for user-friendly toasts
      if (e is ApiException) {
        rethrow;
      }
      throw Exception('회원가입에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 로그인
  Future<AuthResponse> login(UserLoginRequest request) async {
    try {
      print('🔍 AuthService.login 시작');
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: request.toJson(),
      );

      print('🔍 AuthService.login 응답 데이터: ${response.data}');
      print('🔍 AuthService.login 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.data == null) {
        print('❌ AuthService.login: 응답 데이터가 null입니다!');
        throw Exception('로그인 응답 데이터가 null입니다.');
      }
      final Map<String, dynamic> data = response.data!;
      final String? token = (data['token'] ?? data['access_token'])?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('로그인 응답에 토큰이 없습니다.');
      }
      final Map<String, dynamic> userJson =
          (data['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final user = User.fromJson(userJson);

      // 토큰 저장 및 AuthResponse 구성
      _apiService.setToken(token);
      // ApiClient(dio) 경로에서도 동일 토큰 사용되도록 저장
      try {
        await ApiClient().saveToken(token);
        await ApiClient()
            .saveUserIdentity(userId: user.id, email: user.email);
      } catch (_) {}
      final authResponse = AuthResponse(
        accessToken: token,
        tokenType: 'Bearer',
        user: user,
      );
      print('🔍 AuthService.login 완료');
      return authResponse;
    } catch (e) {
      print('❌ AuthService.login 오류: $e');
      print('❌ AuthService.login 오류 타입: ${e.runtimeType}');
      if (e is ApiException) {
        rethrow; // controller/UI가 사용자 친화 메시지로 표시
      }
      throw Exception('로그인에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 내 정보 조회
  Future<User> getMe() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/auth/profile',
      );
      return User.fromJson(response.data!);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('사용자 정보를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      _apiService.clearToken();
      try {
        await ApiClient().clearToken();
        await ApiClient().clearUserIdentity();
      } catch (_) {}
      // 서버에 로그아웃 요청 (필요시)
      // await _apiService.post('/auth/logout');
    } catch (e) {
      // 로그아웃은 실패해도 토큰은 제거
      _apiService.clearToken();
      try {
        await ApiClient().clearToken();
        await ApiClient().clearUserIdentity();
      } catch (_) {}
      throw Exception('로그아웃 처리 중 문제가 발생했습니다.');
    }
  }

  /// 토큰이 있는지 확인
  bool get isLoggedIn => _apiService.currentToken != null;

  /// 현재 토큰 반환
  String? get currentToken => _apiService.currentToken;
}

// 싱글톤 인스턴스
final AuthService authService = AuthService();
