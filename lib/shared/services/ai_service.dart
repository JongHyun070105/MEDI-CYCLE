import '../models/ai_model.dart';
import 'api_service.dart';

class AiService {
  final ApiService _apiService = apiService;

  /// AI 챗봇 (일반 대화)
  Future<AiResponse> chat(AiChatRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/ai/chat',
        data: request.toJson(),
      );
      return AiResponse.fromJson(response.data!);
    } catch (e) {
      throw Exception('AI 챗봇 응답 중 오류가 발생했습니다: $e');
    }
  }

  /// AI 피드백 (의약품 정보)
  Future<AiResponse> feedback(AiFeedbackRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/ai/feedback',
        data: request.toJson(),
      );
      return AiResponse.fromJson(response.data!);
    } catch (e) {
      throw Exception('AI 피드백 응답 중 오류가 발생했습니다: $e');
    }
  }

  /// AI 피드백 로그 조회
  Future<List<AiFeedbackLog>> getFeedbackLogs() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/ai/feedback/logs');
      return response.data!
          .map((json) => AiFeedbackLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('AI 피드백 로그 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 간단한 메시지 전송 (일반 대화)
  Future<String> sendMessage(String message) async {
    try {
      final response = await chat(AiChatRequest(message: message));
      return response.responseText;
    } catch (e) {
      throw Exception('메시지 전송 중 오류가 발생했습니다: $e');
    }
  }

  /// 의약품 정보 질문
  Future<String> askAboutMedication(String medicationName, {String? question}) async {
    try {
      final response = await feedback(AiFeedbackRequest(
        itemName: medicationName,
        question: question,
      ));
      return response.responseText;
    } catch (e) {
      throw Exception('의약품 정보 조회 중 오류가 발생했습니다: $e');
    }
  }
}

// 싱글톤 인스턴스
final AiService aiService = AiService();
