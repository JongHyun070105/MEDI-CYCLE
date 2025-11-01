import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? source;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.source,
  });
}

class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;

  const ChatState({required this.isLoading, required this.messages});

  ChatState copyWith({bool? isLoading, List<ChatMessage>? messages}) =>
      ChatState(
        isLoading: isLoading ?? this.isLoading,
        messages: messages ?? this.messages,
      );
}

class ChatController extends StateNotifier<ChatState> {
  final ApiClient _api = ApiClient();

  ChatController() : super(const ChatState(isLoading: false, messages: []));

  Future<void> loadHistory() async {
    try {
      state = state.copyWith(isLoading: true);
      final data = await _api.getChatHistory();
      final list = List<Map<String, dynamic>>.from(data['messages'] ?? []);
      final messages = list.map((m) {
        final role = (m['role'] ?? '').toString();
        final content = (m['content'] ?? '').toString();
        final createdAt =
            (m['created_at'] ??
                    m['createdAt'] ??
                    DateTime.now().toIso8601String())
                .toString();
        return ChatMessage(
          id: (m['id'] ?? '').toString(),
          content: content,
          isUser: role == 'user',
          timestamp: DateTime.tryParse(createdAt) ?? DateTime.now(),
        );
      }).toList();
      state = state.copyWith(isLoading: false, messages: messages);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String content, {int? medicationId}) async {
    final userMsg = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final resp = await _api.sendChatMessage(
        content: content,
        medicationId: medicationId,
      );
      final ai = resp['aiMessage'] as Map<String, dynamic>?;
      final aiContent =
          (ai != null ? ai['content'] : resp['content'])?.toString() ??
          '응답을 생성할 수 없습니다.';
      final aiCreatedAt =
          (ai != null ? (ai['createdAt'] ?? ai['created_at']) : null)
              ?.toString();
      final aiId =
          (ai != null
                  ? ai['id']
                  : 'local-ai-${DateTime.now().microsecondsSinceEpoch}')
              .toString();
      final botMsg = ChatMessage(
        id: aiId,
        content: aiContent,
        isUser: false,
        timestamp: aiCreatedAt != null
            ? (DateTime.tryParse(aiCreatedAt) ?? DateTime.now())
            : DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      final botMsg = ChatMessage(
        id: 'err-${DateTime.now().microsecondsSinceEpoch}',
        content: 'AI 응답 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    }
  }

  Future<void> clearMessages() async {
    try {
      await _api.deleteChatHistory();
    } catch (_) {}
    state = state.copyWith(messages: []);
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(),
);
