import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isUploading = false;

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        print('Logout error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  // Upload Profile Picture using ImgBB API
  Future<void> _uploadProfilePicture() async {
    print("1. Avatar clicked! Upload process started...");
    final user = _auth.currentUser;

    // Check if user is logged in
    if (user == null) {
      print("Error: User is null!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: You are not logged in! (User is null)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if guest mode
    if (_authService.isGuestMode) {
      print("Error: Guest mode!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest cannot upload photo. Please login.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print("2. Opening file picker...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        print("3. User cancelled file picker.");
        return;
      }

      setState(() {
        _isUploading = true;
      });

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) throw Exception("Failed to read file bytes");

      // Convert to Base64
      print("4. Converting image to Base64...");
      String base64Image = base64Encode(fileBytes);

      // Upload to ImgBB
      const String imgbbApiKey = "a4958619f9b73b278a246275a6f5720a";

      print("5. Sending to ImgBB...");
      final Uri url = Uri.parse("https://api.imgbb.com/1/upload");
      final response = await http.post(url, body: {
        'key': imgbbApiKey,
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String imageUrl = responseData['data']['display_url'];
        print("6. Upload success! Image URL: $imageUrl");

        // Update the user's profile
        await user.updatePhotoURL(imageUrl);
        await user.reload(); // Refresh user data

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } else {
        throw Exception("ImgBB Upload Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Upload Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call _auth.currentUser again to get the refreshed user data
    final user = _auth.currentUser;
    final isGuest = _authService.isGuestMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                // Guest Mode Indicator
                if (isGuest)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded, color: Colors.amber.shade300, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You are in Guest Mode - Create an account to save your progress',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.amber.shade300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // User Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Interactive Profile Avatar
                      GestureDetector(
                        onTap: () {
                          if (!isGuest && !_isUploading) {
                            _uploadProfilePicture();
                          } else if (isGuest) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please login to change profile picture.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              // Show uploaded image if available
                              backgroundImage: (user?.photoURL != null && !isGuest)
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: _isUploading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : (user?.photoURL == null || isGuest)
                                  ? Icon(
                                isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                                size: 60,
                                color: Colors.white,
                              )
                                  : null,
                            ),

                            // Edit / Camera Icon
                            if (!isGuest && !_isUploading)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isGuest ? 'Guest User' : (user?.displayName ?? user?.email ?? 'User'),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (!isGuest && user != null)
                        Text(
                          'UID: ${user.uid.substring(0, 8)}...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      else if (isGuest)
                        Text(
                          'Mode: Guest (No account)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Settings Header
                Text(
                  'Account Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}