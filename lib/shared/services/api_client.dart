import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_service.dart';

const String baseUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'https://colleagues-treat-curtis-hiring.trycloudflare.com',
);

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  late final SharedPreferences prefs;
  bool _initialized = false;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // 인터셉터: 토큰 자동 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // 재시도용 메타 데이터 초기화
          options.extra['retry_count'] =
              (options.extra['retry_count'] ?? 0) as int;
          return handler.next(options);
        },
        onError: (error, handler) async {
          final int status = error.response?.statusCode ?? 0;
          // 401/403: 토큰 만료 처리
          if (status == 401 || status == 403) {
            try {
              await clearToken();
            } catch (_) {}
            NavigationService.forceLogoutToSplash(
              message: '인증이 만료되었습니다. 다시 로그인해주세요.',
            );
            return handler.reject(
              DioException.badResponse(
                statusCode: status,
                requestOptions: error.requestOptions,
                response:
                    error.response ??
                    Response(requestOptions: error.requestOptions, data: null),
              ),
            );
          }

          // 네트워크 오류 재시도(최대 2회, GET 요청 위주)
          final req = error.requestOptions;
          final bool isNetworkError =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.badCertificate ||
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown;
          if (isNetworkError && (req.method == 'GET' || req.method == 'get')) {
            final int retried = (req.extra['retry_count'] ?? 0) as int;
            if (retried < 2) {
              await Future.delayed(Duration(milliseconds: 300 * (retried + 1)));
              req.extra['retry_count'] = retried + 1;
              try {
                final cloned = await dio.fetch(req);
                return handler.resolve(cloned);
              } catch (e) {
                // fallthrough
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<void> initializePrefs() async {
    if (_initialized) return;
    prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // 토큰 저장
  Future<void> saveToken(String token) async {
    if (!_initialized) {
      await initializePrefs();
    }
    await prefs.setString('auth_token', token);
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    if (!_initialized) {
      await initializePrefs();
    }
    return prefs.getString('auth_token');
  }

  // 토큰 삭제
  Future<void> clearToken() async {
    if (!_initialized) {
      await initializePrefs();
    }
    await prefs.remove('auth_token');
  }

  // 자동로그인 플래그 저장/조회
  Future<void> setAutoLoginEnabled(bool enabled) async {
    if (!_initialized) {
      await initializePrefs();
    }
    await prefs.setBool('auto_login_enabled', enabled);
  }

  Future<bool> getAutoLoginEnabled() async {
    if (!_initialized) {
      await initializePrefs();
    }
    return prefs.getBool('auto_login_enabled') ?? true; // 기본값: 허용
  }

  Future<void> saveUserIdentity({
    required int userId,
    required String email,
  }) async {
    if (!_initialized) {
      await initializePrefs();
    }
    await prefs.setInt('auth_user_id', userId);
    await prefs.setString('auth_user_email', email);
  }

  Future<int?> getStoredUserId() async {
    if (!_initialized) {
      await initializePrefs();
    }
    return prefs.getInt('auth_user_id');
  }

  Future<String?> getStoredUserEmail() async {
    if (!_initialized) {
      await initializePrefs();
    }
    return prefs.getString('auth_user_email');
  }

  Future<void> clearUserIdentity() async {
    if (!_initialized) {
      await initializePrefs();
    }
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_user_email');
  }

  // 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode != 200) {
        final errorMsg = response.data is Map<String, dynamic>
            ? response.data['error'] ?? '로그인 실패'
            : '로그인 실패';
        throw Exception(errorMsg);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 프로필 조회
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/api/auth/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 프로필 업데이트
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? name,
    int? age,
    String? address,
    String? gender,
    bool? autoLogin,
  }) async {
    try {
      final response = await dio.put(
        '/api/auth/profile',
        data: {
          if (email != null) 'email': email,
          if (name != null) 'name': name,
          if (age != null) 'age': age,
          if (address != null) 'address': address,
          if (gender != null) 'gender': gender,
          if (autoLogin != null) 'auto_login': autoLogin,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 약 등록
  Future<Map<String, dynamic>> registerMedication({
    required String drugName,
    String? manufacturer,
    String? ingredient,
    required int frequency,
    required List<String> dosageTimes,
    required List<String> mealRelations,
    required List<int> mealOffsets,
    required String startDate,
    String? endDate,
    required bool isIndefinite,
  }) async {
    try {
      final response = await dio.post(
        '/api/medications',
        data: {
          'drug_name': drugName,
          'manufacturer': manufacturer,
          'ingredient': ingredient,
          'frequency': frequency,
          'dosage_times': dosageTimes,
          'meal_relations': mealRelations,
          'meal_offsets': mealOffsets,
          'start_date': startDate,
          'end_date': endDate,
          'is_indefinite': isIndefinite,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 약 목록 조회
  Future<Map<String, dynamic>> getMedications() async {
    try {
      final response = await dio.get('/api/medications');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 약 상세 조회
  Future<Map<String, dynamic>> getMedicationById(int id) async {
    try {
      final response = await dio.get('/api/medications/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 약 수정
  Future<Map<String, dynamic>> updateMedication(
    int id, {
    String? drugName,
    String? manufacturer,
    String? ingredient,
    int? frequency,
    List<String>? dosageTimes,
    List<String>? mealRelations,
    List<int>? mealOffsets,
    String? startDate,
    String? endDate,
    bool? isIndefinite,
  }) async {
    try {
      final response = await dio.put(
        '/api/medications/$id',
        data: {
          if (drugName != null) 'drug_name': drugName,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (ingredient != null) 'ingredient': ingredient,
          if (frequency != null) 'frequency': frequency,
          if (dosageTimes != null) 'dosage_times': dosageTimes,
          if (mealRelations != null) 'meal_relations': mealRelations,
          if (mealOffsets != null) 'meal_offsets': mealOffsets,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (isIndefinite != null) 'is_indefinite': isIndefinite,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 약 삭제
  Future<void> deleteMedication(int id) async {
    try {
      await dio.delete('/api/medications/$id');
    } catch (e) {
      rethrow;
    }
  }

  // 복용 기록 저장
  Future<Map<String, dynamic>> recordMedicationIntake({
    required int medicationId,
    required String intakeTime,
    required bool isTaken,
  }) async {
    try {
      final response = await dio.post(
        '/api/medications/intake/record',
        data: {
          'medication_id': medicationId,
          'intake_time': intakeTime,
          'is_taken': isTaken,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 복용 기록 조회
  Future<Map<String, dynamic>> getMedicationIntakes({
    int? medicationId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await dio.get(
        '/api/medications/intake/list',
        queryParameters: {
          if (medicationId != null) 'medication_id': medicationId,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 복용 기록 업데이트
  Future<Map<String, dynamic>> updateMedicationIntake(
    int id, {
    required bool isTaken,
  }) async {
    try {
      final response = await dio.put(
        '/api/medications/intake/$id',
        data: {'is_taken': isTaken},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 복용 기록 삭제
  Future<void> deleteMedicationIntake(int id) async {
    try {
      await dio.delete('/api/medications/intake/$id');
    } catch (e) {
      rethrow;
    }
  }

  // 채팅 메시지 전송
  Future<Map<String, dynamic>> sendChatMessage({
    required String content,
    int? medicationId,
  }) async {
    try {
      final response = await dio.post(
        '/api/medications/chat/send',
        data: {
          'content': content,
          if (medicationId != null) 'medication_id': medicationId,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 채팅 이력 조회
  Future<Map<String, dynamic>> getChatHistory() async {
    try {
      final response = await dio.get('/api/medications/chat/history');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 채팅 이력 삭제
  Future<void> deleteChatHistory() async {
    try {
      await dio.delete('/api/medications/chat/history');
    } catch (e) {
      rethrow;
    }
  }

  // 월별 복용률 집계 조회
  Future<Map<String, dynamic>> getMonthlyAdherenceStats() async {
    try {
      final response = await dio.get(
        '/api/medications/stats/adherence/monthly',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 건강 인사이트 조회
  Future<Map<String, dynamic>> getHealthInsights() async {
    try {
      final response = await dio.get('/api/medications/stats/insights');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // 유효기간 임박/만료 조회
  Future<Map<String, dynamic>> getExpiryStatus({int windowDays = 30}) async {
    try {
      final response = await dio.get(
        '/api/medications/expiry/list',
        queryParameters: {'window': windowDays},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // 유효기간 정보 수동 업데이트 트리거
  Future<void> triggerExpiryCheck() async {
    try {
      await dio.post('/api/medications/expiry/check');
    } catch (e) {
      // ignore
    }
  }

  // 개인화된 알림 스케줄 조회
  Future<Map<String, dynamic>> getPersonalizedSchedule({
    required String medicationType,
  }) async {
    try {
      final response = await dio.get(
        '/api/medications/personalized-schedule',
        queryParameters: {'medication_type': medicationType},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
