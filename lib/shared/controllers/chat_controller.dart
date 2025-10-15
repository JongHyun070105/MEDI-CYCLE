import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/ai_service.dart';

part 'chat_controller.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    String? source,
  }) = _ChatMessage;
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _ChatState;
}

class ChatController extends StateNotifier<ChatState> {
  final AiService _aiService = aiService;

  ChatController() : super(const ChatState());

  /// 일반 대화 메시지 전송
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _aiService.sendMessage(message);

      // AI 응답 메시지 추가
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        source: 'gemini',
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 의약품 정보 질문
  Future<void> askAboutMedication(
    String medicationName, {
    String? question,
  }) async {
    final message = question ?? '$medicationName에 대해 알려주세요';

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _aiService.askAboutMedication(
        medicationName,
        question: question,
      );

      // AI 응답 메시지 추가
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        source: 'mixed',
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// 채팅 기록 초기화
  void clearMessages() {
    state = state.copyWith(messages: [], hasError: false, errorMessage: null);
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(hasError: false, errorMessage: null);
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(),
);
