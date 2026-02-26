import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/widgets/ui_kit.dart';

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text":
          "Hello! I am your AI Education Advisor. Ask me anything about universities, scholarships, or career paths in Malaysia!",
    },
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    final response = await _geminiService.chatWithGemini(text);

    if (mounted) {
      setState(() {
        _messages.add({"role": "bot", "text": response});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                "AI Education Advisor",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Chat Area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ).animate().fade().scale(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                );
              },
            ),
          ),
        ),

        // Input Area
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Ask about scholarships, courses...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ModernButton(
              label: "Send",
              icon: Icons.send,
              onPressed: _isLoading ? null : _sendMessage,
              isLoading: _isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
