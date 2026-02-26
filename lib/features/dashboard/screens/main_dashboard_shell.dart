import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/widgets/ui_kit.dart';
import 'ai_chat_tab.dart';
import 'profile_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../admission/presentation/qualification_screen.dart';
import '../../career/presentation/career_list_screen.dart';
import '../../scholarship/presentation/scholarship_screen.dart';

import '../../auth/screens/login_screen.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Ensure this package is added or remove if unused

class MainDashboardShell extends StatefulWidget {
  const MainDashboardShell({super.key});

  @override
  State<MainDashboardShell> createState() => _MainDashboardShellState();
}

class _MainDashboardShellState extends State<MainDashboardShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Analysis Dashboard (Your Profile Analysis)")),
    const AiChatTab(),
    const QualificationScreen(), // Index 0: Admission
    const CareerListScreen(),      // Index 1: Career
    const ScholarshipScreen(),     // Index 2: Scholarships
    const ProfileSettingsScreen(), // Index 3: Profile (Warren's)
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserSessionModel>(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50, Colors.white],
          ),
        ),
        child: Row(
          children: [
            if (isDesktop) _buildSideBar(context, userModel),
            Expanded(
              child: Column(
                children: [
                  if (!isDesktop) _buildMobileAppBar(context, userModel),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GlassContainer(
                        opacity: 0.5,
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'Analysis',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'AI Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  label: 'Scholarships',
                ),
                NavigationDestination(
                  icon: Icon(Icons.article_outlined),
                  label: 'News',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }

  Widget _buildSideBar(BuildContext context, UserSessionModel userModel) {
    return GlassContainer(
      width: 280,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      opacity: 0.8,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.school,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "EduNavigator",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _SideBarItem(
            icon: Icons.analytics_outlined,
            label: "Analysis",
            isSelected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _SideBarItem(
            icon: Icons.chat_bubble_outline,
            label: "AI Advisor",
            isSelected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _SideBarItem(
            icon: Icons.school_outlined,
            label: "Scholarships",
            isSelected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          _SideBarItem(
            icon: Icons.article_outlined,
            label: "News & Info",
            isSelected: _selectedIndex == 3,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
          _SideBarItem(
            icon: Icons.person_outline,
            label: "Profile",
            isSelected: _selectedIndex == 4,
            onTap: () => setState(() => _selectedIndex = 4),
          ),
          const Spacer(),
          const Divider(),
          _SideBarItem(
            icon: Icons.person_pin,
            label: userModel.fullName.isNotEmpty
                ? userModel.fullName
                : 'Guest User',
            isSelected: _selectedIndex == 4,
            onTap: () => setState(() => _selectedIndex = 4),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context, UserSessionModel userModel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "EduNavigator",
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            child: Text(
              (userModel.fullName.isNotEmpty ? userModel.fullName : 'G')[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _SideBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
