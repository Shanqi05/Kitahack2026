import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Import BudgetInputScreen to navigate there next
import 'budget_input_screen.dart';
import 'admission_chat_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final PlatformFile? resumeFile;
  final String? stream; // Science, Commerce, Arts

  const InterestSelectionScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    this.resumeFile,
    this.stream,
  });

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> with TickerProviderStateMixin {
  // Hardcoded list of interests with icons
  final interests = [
    {"name": "Information Technology", "short": "IT", "icon": Icons.computer},
    {"name": "Artificial Intelligence", "short": "AI", "icon": Icons.smart_toy},
    {"name": "Data Science", "short": "Data Science", "icon": Icons.analytics},
    {"name": "Engineering", "short": "Engineering", "icon": Icons.build},
    {"name": "Business & Finance", "short": "Business", "icon": Icons.trending_up},
    {"name": "Finance & Accounting", "short": "Finance", "icon": Icons.calculate},
    {"name": "Health & Biomedical", "short": "Health Science", "icon": Icons.medical_services},
    {"name": "Psychology", "short": "Psychology", "icon": Icons.psychology},
    {"name": "Science", "short": "Science", "icon": Icons.science},
    {"name": "Communication", "short": "Communication", "icon": Icons.mail},
    {"name": "Arts & Design", "short": "Arts", "icon": Icons.palette},
    {"name": "Law", "short": "Law", "icon": Icons.gavel},
  ];

  final selected = <String>[];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Interests"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'What Interests You?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select at least one field to get recommendations',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: interests.map((interest) {
                          final isSelected = selected.contains(interest["short"]);
                          return _buildInterestCard(
                            interest["name"] as String,
                            interest["short"] as String,
                            interest["icon"] as IconData,
                            isSelected,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat with AI Consultant Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selected.isEmpty ? null : () {
                          // Navigate to AdmissionChatScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdmissionChatScreen(
                                qualification: widget.qualification,
                                upu: widget.upu,
                                grades: widget.grades,
                                interests: selected,
                                resumeFile: widget.resumeFile,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat with AI Consultant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                          foregroundColor: const Color(0xFF673AB7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selected.isEmpty ? null : () {
                          // Navigate to BudgetInputScreen passing all data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetInputScreen(
                                qualification: widget.qualification,
                                upu: widget.upu,
                                grades: widget.grades,
                                interests: selected,
                                resumeFile: widget.resumeFile,
                                stream: widget.stream,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Next: Set Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestCard(String name, String shortName, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isSelected ? selected.remove(shortName) : selected.add(shortName)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF673AB7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF673AB7) : Colors.grey[300]!),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF673AB7).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.white : const Color(0xFF673AB7)),
            const SizedBox(height: 8),
            Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}