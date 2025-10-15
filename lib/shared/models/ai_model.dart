import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

@freezed
class AiChatRequest with _$AiChatRequest {
  const factory AiChatRequest({
    required String message,
  }) = _AiChatRequest;

  factory AiChatRequest.fromJson(Map<String, dynamic> json) => 
      _$AiChatRequestFromJson(json);
}

@freezed
class AiFeedbackRequest with _$AiFeedbackRequest {
  const factory AiFeedbackRequest({
    String? itemName,
    String? entpName,
    String? question,
    String? context,
  }) = _AiFeedbackRequest;

  factory AiFeedbackRequest.fromJson(Map<String, dynamic> json) => 
      _$AiFeedbackRequestFromJson(json);
}

@freezed
class AiResponse with _$AiResponse {
  const factory AiResponse({
    String? reply,
    String? answer,
    String? answerType,
    String? productName,
    required String source,
    DateTime? createdAt,
  }) = _AiResponse;

  factory AiResponse.fromJson(Map<String, dynamic> json) => 
      _$AiResponseFromJson(json);
}

// AiResponse 확장 클래스
extension AiResponseExtension on AiResponse {
  // 응답 텍스트 가져오기
  String get responseText => reply ?? answer ?? '';
}

@freezed
class AiFeedbackLog with _$AiFeedbackLog {
  const factory AiFeedbackLog({
    required int id,
    required int userId,
    required String kind,
    required String requestText,
    String? responseText,
    required String source,
    required DateTime createdAt,
  }) = _AiFeedbackLog;

  factory AiFeedbackLog.fromJson(Map<String, dynamic> json) => 
      _$AiFeedbackLogFromJson(json);
}
