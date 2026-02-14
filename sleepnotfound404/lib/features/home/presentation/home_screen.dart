import 'package:flutter/material.dart';
import 'package:sleepnotfound404/features/chat_guidance/presentation/chat_screen.dart';
import 'package:sleepnotfound404/features/admission/presentation/qualification_screen.dart';
import '../../career/presentation/career_list_screen.dart';
import '../../scholarship/presentation/scholarship_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      // FAB for AI Chatbot
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF673AB7)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF673AB7),
                Color(0xFF512DA8),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(),
                    const SizedBox(height: 30),

                    // Updated Grid with Admission, Career, Scholarship
                    _buildSelectionGrid(context),

                    const SizedBox(height: 40),
                    _buildFeaturesSection(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar (Unchanged)
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Career Path Finder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 60, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 10),
              Text(
                'Discover Your Future',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome section (Unchanged)
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome! 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Let us help you discover the perfect university course based on your profile and interests.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Updated Grid: Admission | Career | Scholarship
  Widget _buildSelectionGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Path',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 1. Admission
            Expanded(
              child: _buildSmallOptionCard(
                context,
                title: "Admission",
                icon: Icons.school_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QualificationScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // 2. Career Insights (New)
            Expanded(
              child: _buildSmallOptionCard(
                context,
                title: "Career",
                icon: Icons.work_rounded,
                onTap: () {
                  // Navigate to Career Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CareerListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // 3. Scholarship (New)
            Expanded(
              child: _buildSmallOptionCard(
                context,
                title: "Scholarship",
                icon: Icons.monetization_on_rounded,
                onTap: () {
                  // Navigate to Scholarship Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScholarshipScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget (Unchanged)
  Widget _buildSmallOptionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Features section (Unchanged)
  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Use Career Path Finder?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.bolt_rounded,
          title: 'AI-Powered Analysis',
          description: 'Get instant career insights using advanced AI',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.school_rounded,
          title: 'Malaysian Universities',
          description: 'Recommendations from top Malaysian institutions',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.check_circle_rounded,
          title: 'Personalized Paths',
          description: 'Get courses tailored to your profile and interests',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}