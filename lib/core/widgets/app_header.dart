import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../features/dashboard/screens/profile_screen.dart';
import '../../features/home/presentation/home_screen.dart';

class AppHeader extends StatelessWidget {
  final bool showNotifications;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    this.showNotifications = false,
    this.onNotificationTap,
    this.showBackButton = false,
    this.onBackPressed,
  });

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user and guest status
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = AuthService().isGuestMode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Back button + EduNavigator Logo
            Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: () {
                      if (onBackPressed != null) {
                        onBackPressed!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (showBackButton) const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _navigateToHome(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'EduNavigator',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Right: Notifications + Profile Icon
            Row(
              children: [
                if (showNotifications)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: onNotificationTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ).then((_) {
                      // Trigger rebuild when returning from profile screen
                      // to update the header image if it changed
                      (context as Element).markNeedsBuild();
                    });
                  },
                  child: Container(
                    width: 42, // Fixed width for circular consistency
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    // Check if not guest, user exists, and has photoURL
                    child: (!isGuest && user != null)
                        ? (user.photoURL != null)
                        ? ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Center(
                      child: Text(
                        user.email != null && user.email!.isNotEmpty
                            ? user.email![0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : const Icon(
                      Icons.person_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}