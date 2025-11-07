import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://cult-physically-fire-pink.trycloudflare.com',
  );
  late final Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 요청 인터셉터 - 토큰 자동 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          if (kDebugMode) {
            print('🚀 API Request: ${options.method} ${options.uri}');
            print('📦 Headers: ${options.headers}');
            if (options.data != null) {
              print('📋 Data: ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print('📄 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
              '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
            );
            print('💥 Error: ${error.message}');
            if (error.response?.data != null) {
              print('📄 Error Data: ${error.response?.data}');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // 토큰 설정
  void setToken(String token) {
    _token = token;
  }

  // 토큰 제거
  void clearToken() {
    _token = null;
  }

  /// SharedPreferences에 저장된 토큰을 동기화하여 자동 로그인을 지원합니다.
  Future<void> syncTokenFromStorage() async {
    if (_token != null) return; // 이미 메모리에 로드됨
    try {
      final saved = await ApiClient().getToken();
      if (saved != null && saved.isNotEmpty) {
        _token = saved;
      }
    } catch (_) {
      // 저장소 접근 실패 시 무시하고 비로그인 상태 유지
    }
  }

  /// 토큰이 있는지 확인
  bool get isLoggedIn => _token != null;

  /// 현재 토큰 반환
  String? get currentToken => _token;

  // GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Dio 에러 처리
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('연결 시간이 초과되었습니다.', 408);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final data = error.response?.data;
        String message = '서버 오류가 발생했습니다.';
        if (data is Map<String, dynamic>) {
          message =
              (data['error'] ?? data['detail'] ?? data['message'] ?? message)
                  .toString();
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }
        // 사용자 친화적 메시지 매핑
        if (statusCode == 400 && message.contains('이미 등록된')) {
          message = '이미 존재하는 이메일입니다.';
        } else if (statusCode == 401) {
          // 로그인 실패 문구는 그대로 노출, 그 외 401은 일반 문구
          if (!message.contains('이메일 또는 비밀번호')) {
            message = '인증이 필요합니다. 다시 로그인해주세요.';
          }
        } else if (statusCode == 404) {
          message = '요청하신 자원을 찾을 수 없습니다.';
        }
        return ApiException(message, statusCode);
      case DioExceptionType.cancel:
        return ApiException('요청이 취소되었습니다.', -1);
      case DioExceptionType.connectionError:
        return ApiException('네트워크 연결을 확인해주세요.', 0);
      case DioExceptionType.badCertificate:
        return ApiException('SSL 인증서 오류가 발생했습니다.', 495);
      case DioExceptionType.unknown:
        return ApiException('알 수 없는 오류가 발생했습니다.', -1);
    }
  }

  // 헬스 체크
  Future<bool> healthCheck() async {
    try {
      final response = await get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// 싱글톤 인스턴스
final ApiService apiService = ApiService();
