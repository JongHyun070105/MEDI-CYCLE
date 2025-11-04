import 'package:flutter/foundation.dart';
import 'api_service.dart';

class FeedbackService {
  final ApiService _apiService = apiService;

  /// 약물 복용 피드백 제출
  Future<void> submitFeedback({
    required int medicationId,
    required bool taken,
    int? notificationId,
    String? actualTime, // HH:MM 형식
    int? mealTime, // 분 단위
    int? medicationTime, // 분 단위
    int? feedbackScore, // 1-5
    int? satisfaction, // 1-5
    int? timeAccuracy, // 1-5
  }) async {
    try {
      debugPrint('📝 피드백 제출 시작: 약물 ID=$medicationId, 복용=$taken');

      final response = await _apiService.post(
        '/api/medications/$medicationId/feedback',
        data: {
          'taken': taken,
          if (notificationId != null) 'notification_id': notificationId,
          if (actualTime != null) 'actual_time': actualTime,
          if (mealTime != null) 'meal_time': mealTime,
          if (medicationTime != null) 'medication_time': medicationTime,
          if (feedbackScore != null) 'feedback_score': feedbackScore,
          if (satisfaction != null) 'satisfaction': satisfaction,
          if (timeAccuracy != null) 'time_accuracy': timeAccuracy,
        },
      );

      if (response.statusCode == 201) {
        debugPrint('✅ 피드백 제출 성공: 약물 ID=$medicationId');
        return;
      } else {
        throw Exception('피드백 제출 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 피드백 제출 오류: $e');
      rethrow;
    }
  }
}

// 싱글톤 인스턴스
final FeedbackService feedbackService = FeedbackService();

