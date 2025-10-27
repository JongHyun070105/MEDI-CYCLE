import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://localhost:3000';

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
          return handler.next(options);
        },
        onError: (error, handler) {
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
    await prefs.setString('auth_token', token);
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    return prefs.getString('auth_token');
  }

  // 토큰 삭제
  Future<void> clearToken() async {
    await prefs.remove('auth_token');
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
        throw Exception(response.data['error'] ?? '로그인 실패');
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
}
