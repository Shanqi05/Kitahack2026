import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'admission_chat_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final PlatformFile? resumeFile;

  const InterestSelectionScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    this.resumeFile,
  });

  @override
  State<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen>
    with TickerProviderStateMixin {
  final interests = [
    {"name": "Information Technology", "short": "IT", "icon": Icons.computer},
    {"name": "Engineering", "short": "Engineering", "icon": Icons.build},
    {"name": "Business & Finance", "short": "BF", "icon": Icons.trending_up},
    {
      "name": "Health & Biomedical",
      "short": "HBP",
      "icon": Icons.medical_services
    },
    {"name": "Psychology", "short": "Psych", "icon": Icons.psychology},
    {
      "name": "Health Science",
      "short": "Health",
      "icon": Icons.health_and_safety
    },
  ];
  final selected = <String>[];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                    const Text(
                      'What Interests You?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select at least one field of interest to get personalized recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: interests.map((interest) {
                        final isSelected =
                            selected.contains(interest["short"]);
                        return _buildInterestCard(
                          interest["name"] as String,
                          interest["short"] as String,
                          interest["icon"] as IconData,
                          isSelected,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                      secondaryAnimation) {
                                    return AdmissionChatScreen(
                                      qualification: widget.qualification,
                                      upu: widget.upu,
                                      grades: widget.grades,
                                      interests: selected,
                                      resumeFile: widget.resumeFile,
                                    );
                                  },
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Chat with Academic Consultant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestCard(
    String name,
    String shortName,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? selected.remove(shortName) : selected.add(shortName);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFF673AB7).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF673AB7)
                : const Color(0xFF673AB7).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF673AB7).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : const Color(0xFF673AB7),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
