import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sleepnotfound404/services/gemini_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'budget_input_screen.dart';

class AdmissionChatScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final PlatformFile? resumeFile;

  const AdmissionChatScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.resumeFile,
  });

  @override
  State<AdmissionChatScreen> createState() => _AdmissionChatScreenState();
}

class _AdmissionChatScreenState extends State<AdmissionChatScreen> {
  GeminiService? _gemini;
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize GeminiService with error handling
    try {
      _gemini = GeminiService();
      debugPrint('GeminiService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing GeminiService: $e');
      _gemini = null;
    }

    // Initial greeting message from academic consultant
    _messages.add(
      Message(
        text:
            'Hi! 👋 I\'m your Academic Consultant. Based on your interests in ${widget.interests.join(", ")}, I\'m here to help you explore the perfect course for your future.\n\nFeel free to ask me anything about these courses, careers, or university life!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(
        Message(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get response from Gemini (or fallback if not initialized)
      final response = _gemini != null
          ? await _gemini!.sendMessage(text)
          : _getFallbackResponse(text);

      setState(() {
        _messages.add(
          Message(text: response, isUser: false, timestamp: DateTime.now()),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        _messages.add(
          Message(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('course') || lowerMessage.contains('program')) {
      return "Great question! Based on your interests, I recommend exploring programs in ${widget.interests.join(", ")}. These fields have excellent job prospects and align well with modern career paths.";
    } else if (lowerMessage.contains('career') ||
        lowerMessage.contains('job')) {
      return "The tech industry offers many exciting career paths! You could consider roles like Software Developer, Data Analyst, UX Designer, or Product Manager. Each has unique challenges and rewards.";
    } else if (lowerMessage.contains('university') ||
        lowerMessage.contains('uni')) {
      return "When choosing a university, consider factors like: program reputation, internship opportunities, campus culture, and post-graduation employment rates. I recommend researching programs that align with your interests.";
    } else {
      return "That's an interesting question! I'm here to help guide you through your career exploration. Feel free to ask about specific fields, universities, or career paths.";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Consultant"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BudgetInputScreen(
                            qualification: widget.qualification,
                            upu: widget.upu,
                            grades: widget.grades,
                            interests: widget.interests,
                            resumeFile: widget.resumeFile,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF673AB7),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
                child: const Text('Get Results'),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color(0xFF673AB7)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinKitWave(color: const Color(0xFF673AB7), size: 40),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey[300] ?? Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey[300] ?? Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF673AB7),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_messageController.text),
                    backgroundColor: const Color(0xFF673AB7),
                    disabledElevation: 0,
                    elevation: 4,
                    child: Icon(
                      Icons.send_rounded,
                      color: _isLoading ? Colors.grey : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, required this.timestamp});
}
