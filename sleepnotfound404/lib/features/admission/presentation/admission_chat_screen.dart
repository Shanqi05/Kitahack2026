import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Use relative import to ensure the file is found
import '../../../services/gemini_service.dart';

class AdmissionChatScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final double? budget;
  final PlatformFile? resumeFile;
  final String? stream;
  final String? diplomaField;

  const AdmissionChatScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.budget,
    this.resumeFile,
    this.stream,
    this.diplomaField,
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

    // Initial greeting message from academic consultant (Your original message)
    _messages.add(
      Message(
        text:
        'Hi! 👋 I\'m your Academic Consultant. Based on your profile:'
        '\n• Qualification: ${widget.qualification}'
        '\n• Interests in: ${widget.interests.join(", ")}'
        '${widget.budget != null ? '\n• Budget: RM \$${widget.budget!.toStringAsFixed(0)}/year' : ''}'
        '\n\nI\'m here to help you find the perfect course and university in Malaysia.'
        '\n\nFeel free to ask me about:'
        '\n- Course recommendations'
        '\n- University options within your budget'
        '\n- Career paths'
        '\n- Scholarship opportunities'
        '\n- Program requirements',
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

    // Add user message to UI
    setState(() {
      _messages.add(
        Message(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String response;

      // Try to get response from Gemini if available
      if (_gemini != null) {
        // --- Context Injection ---
        // We wrap the user's question with their profile data so the AI knows the context.
        // This is hidden from the UI but sent to the API.
        String contextPrompt = """
You are an academic counselor for a student in Malaysia.
Student Profile:
- Qualification: ${widget.qualification}
- Interests: ${widget.interests.join(', ')}
- Grades: ${widget.grades.entries.where((e) => e.key != 'CGPA').map((e) => '${e.key}: ${e.value}').join(', ')}
- CGPA: ${widget.grades['CGPA'] ?? 'Not provided'}
- Application Mode: ${widget.upu ? 'UPU (Public Uni)' : 'Private Uni'}
- Budget: ${widget.budget != null ? 'RM \$${widget.budget!.toStringAsFixed(0)}/year' : 'Not specified'}
- Resume: ${widget.resumeFile != null ? widget.resumeFile!.name : 'Not provided'}

The student asks: "$text"

Please provide a helpful, encouraging, and specific answer based on their profile. 
If they ask about schools or universities, suggest Malaysian institutions within their budget.
If they ask about programs, recommend courses that match their interests and qualifications.
Keep responses concise and actionable.
""";

        // Send the context-aware prompt
        response = await _gemini!.sendMessage(contextPrompt);
      } else {
        // If GeminiService is not available, use a simple fallback (Your original message)
        response =
        "I'm having trouble connecting to the AI service right now. "
            "However, based on your interests in ${widget.interests.join(", ")}, "
            "I can suggest exploring courses and universities that align with these fields. "
            "Would you like recommendations on specific programs?";
      }

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
            text: 'Sorry, I encountered an error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
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
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF673AB7),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
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
                      // Added max width constraint to prevent messages from spanning full width
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color(0xFF673AB7)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                          bottomRight: Radius.circular(message.isUser ? 4 : 16),
                        ),
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
                child: SpinKitThreeBounce(color: const Color(0xFF673AB7), size: 24),
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
                      // Allow sending by pressing "Enter" on keyboard
                      onSubmitted: (value) {
                        if (!_isLoading) _sendMessage(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
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
                  CircleAvatar(
                    backgroundColor: const Color(0xFF673AB7),
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(_messageController.text),
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
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