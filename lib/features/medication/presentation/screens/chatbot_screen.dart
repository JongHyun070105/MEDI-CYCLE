import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/controllers/chat_controller.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key, this.medicationId, this.medicationName});

  final int? medicationId;
  final String? medicationName;

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSuggestedQuestions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? preset}) async {
    final String message = (preset ?? _messageController.text).trim();
    if (message.isEmpty) return;
    _messageController.clear();
    setState(() {
      _showSuggestedQuestions = true;
    });
    final chatController = ref.read(chatControllerProvider.notifier);
    await chatController.sendMessage(
      message,
      medicationId: widget.medicationId,
    );
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<String> _buildSuggestedQuestions() {
    final String drug = widget.medicationName ?? '이 약';
    return <String>[
      '$drug의 주요 효능은 뭐야?',
      '$drug의 부작용이 뭐야?',
      '$drug 복용 시간과 식사와의 관계는?',
      '$drug 다른 약과 상호작용 있어?',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    // 메시지 리스트 변화 감지하여 자동 스크롤
    ref.listen(chatControllerProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('AI 챗봇'),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                onPressed: () {
                  ref.read(chatControllerProvider.notifier).clearMessages();
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 채팅 메시지 리스트
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: chatState.messages.isEmpty
                        ? 1
                        : chatState.messages.length,
                    itemBuilder: (context, index) {
                      if (chatState.messages.isEmpty) {
                        return _buildWelcomeMessage();
                      }
                      return _buildMessageBubble(chatState.messages[index]);
                    },
                  ),
                ),

                // 추천 질문 칩 (입력창 위) - 텍스트 입력 시 숨김
                if (_showSuggestedQuestions && _messageController.text.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildSuggestedQuestions()
                            .map(
                              (q) => Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSizes.sm,
                                ),
                                child: ActionChip(
                                  label: Text(
                                    q,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  backgroundColor: AppColors.surface,
                                  side: BorderSide(color: AppColors.border),
                                  onPressed: chatState.isLoading
                                      ? null
                                      : () => _sendMessage(preset: q),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                // 메시지 입력 영역 (하단 버튼 겹침 방지: SafeArea + padding)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.sm,
                      AppSizes.md,
                      AppSizes.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLg,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLg,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLg,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            onChanged: (value) {
                              setState(() {
                                _showSuggestedQuestions = value.isEmpty;
                              });
                            },
                            enabled: !chatState.isLoading,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusRound,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: chatState.isLoading
                                ? null
                                : () => _sendMessage(),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSizes.sm),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요! 약드셔유 AI 챗봇입니다. 약물 복용과 관련해서 궁금한 것이 있으시면 언제든지 물어보세요!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSizes.sm),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sanitizeMarkdown(message.content),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: message.isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSizes.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // 매우 간단한 마크다운 제거/치환: **bold** -> bold, * bullet -> •
  String _sanitizeMarkdown(String text) {
    String out = text.replaceAll('**', '');
    out = out.replaceAll(RegExp(r'^\*\s', multiLine: true), '• ');
    out = out.replaceAll(RegExp(r'^-\s', multiLine: true), '• ');
    // strip code fences and language hint
    out = out.replaceAll('```python', '');
    out = out.replaceAll('```', '');
    return out.trim();
  }
}
