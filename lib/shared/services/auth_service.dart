import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = apiService;

  /// 회원가입
  Future<AuthResponse> signup(UserSignupRequest request) async {
    try {
      // 1. 회원가입 요청
      final signupResponse = await _apiService.post<Map<String, dynamic>>(
        '/auth/signup',
        data: request.toJson(),
      );

      // 2. 회원가입 성공 후 자동 로그인
      final loginResponse = await login(
        UserLoginRequest(email: request.email, password: request.password),
      );

      return loginResponse;
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그인
  Future<AuthResponse> login(UserLoginRequest request) async {
    try {
      print('🔍 AuthService.login 시작');
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      print('🔍 AuthService.login 응답 데이터: ${response.data}');
      print('🔍 AuthService.login 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.data == null) {
        print('❌ AuthService.login: 응답 데이터가 null입니다!');
        throw Exception('로그인 응답 데이터가 null입니다.');
      }

      print('🔍 AuthResponse.fromJson 호출 전');
      final authResponse = AuthResponse.fromJson(response.data!);
      print('🔍 AuthResponse.fromJson 성공: $authResponse');

      // 토큰 저장
      _apiService.setToken(authResponse.accessToken);
      print('🔍 AuthService.login 완료');

      return authResponse;
    } catch (e) {
      print('❌ AuthService.login 오류: $e');
      print('❌ AuthService.login 오류 타입: ${e.runtimeType}');
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 내 정보 조회
  Future<User> getMe() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/auth/me');
      return User.fromJson(response.data!);
    } catch (e) {
      throw Exception('사용자 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      _apiService.clearToken();
      // 서버에 로그아웃 요청 (필요시)
      // await _apiService.post('/auth/logout');
    } catch (e) {
      // 로그아웃은 실패해도 토큰은 제거
      _apiService.clearToken();
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 토큰이 있는지 확인
  bool get isLoggedIn => _apiService.currentToken != null;

  /// 현재 토큰 반환
  String? get currentToken => _apiService.currentToken;
}

// 싱글톤 인스턴스
final AuthService authService = AuthService();
