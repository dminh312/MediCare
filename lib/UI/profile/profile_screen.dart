import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicare/UI/login/login_screen.dart';
import 'package:medicare/UI/profile/account_setting/health_records_screen.dart';
import 'package:medicare/UI/profile/account_setting/personal_information_screen.dart';
import 'package:medicare/UI/profile/account_setting/security_privacy_screen.dart';
import 'package:medicare/UI/profile/notification_setting/notification_setting_screen.dart';
import 'package:medicare/UI/profile/support/support_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Profile Page Widget
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && _user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        File file = File(image.path);
        String fileName = 'profile_${_user!.uid}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update photoURL in Firebase Auth
        await _user!.updatePhotoURL(downloadUrl);

        // Update photoURL in Firestore
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'photoURL': downloadUrl,
          'updatedAt': Timestamp.now(),
        });

        // Refresh user to get the latest data
        await FirebaseAuth.instance.currentUser?.reload();
        setState(() {
          _user = FirebaseAuth.instance.currentUser;
          _isLoading = false;
        });

        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully!')),
            );
        }

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
        }
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors from the design
    const primaryColor = Color(0xFFff5252);
    const primaryLightColor = Color(0xFFffebee);
    const backgroundLightColor = Color(0xFFfdf8f8);

    // Check for dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use appropriate background color
    final backgroundColor = isDarkMode ? const Color(0xFF1a1111) : backgroundLightColor;
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111714);
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];

    return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, isDarkMode, primaryColor, textColor, secondaryTextColor)
                .animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSettingsSection(
                    context: context,
                    title: 'ACCOUNT SETTINGS',
                    isDarkMode: isDarkMode,
                    surfaceColor: surfaceColor,
                    primaryColor: primaryColor,
                    items: [
                      _buildSettingsItem(context, Icons.person, const Color(0xFFfce4ec), const Color(0xFFe91e63), 'Personal Information', isDarkMode, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInformationScreen()));
                      }),
                      _buildSettingsItem(context, Icons.description, const Color(0xFFffebee), primaryColor, 'Health Records', isDarkMode, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthRecordsScreen()));
                      }),
                      _buildSettingsItem(context, Icons.notifications, const Color(0xFFfff3e0), const Color(0xFFFF9800), 'Notification Settings', isDarkMode, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingScreen()));
                      }),
                      _buildSettingsItem(context, Icons.security, const Color(0xFFe3f2fd), const Color(0xFF2196F3), 'Security & Privacy', isDarkMode, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPrivacyScreen()));
                      }),
                    ],
                  ).animate().fade(duration: 400.ms, delay: 200.ms).slideX(begin: 0.1, curve: Curves.easeOutQuad),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context: context,
                    title: 'SUPPORT',
                    isDarkMode: isDarkMode,
                    surfaceColor: surfaceColor,
                    primaryColor: primaryColor,
                    items: [
                      _buildSettingsItem(context, Icons.help_center, const Color(0xFFf3e5f5), const Color(0xFF9c27b0), 'Help & Support', isDarkMode, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
                      }),
                    ],
                  ).animate().fade(duration: 400.ms, delay: 400.ms).slideX(begin: 0.1, curve: Curves.easeOutQuad),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, primaryLightColor, primaryColor, isDarkMode)
                      .animate().fade(duration: 400.ms, delay: 600.ms).scaleXY(begin: 0.9, curve: Curves.easeOutQuad),
                  const SizedBox(height: 24),
                  Text(
                    'Version 0.0.1',
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 120), // Padding for the bottom nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDarkMode, Color primaryColor, Color? textColor, Color? secondaryTextColor) {
    ImageProvider<Object> backgroundImage;
    if (_user?.photoURL != null) {
      backgroundImage = NetworkImage(_user!.photoURL!);
    } else {
      backgroundImage = const AssetImage('assets/def.png');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 32),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
                colors: [Color(0xFF2d1f1f), Color(0xFF1a1111)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFFffebee), Color(0xFFfdf8f8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        color: isDarkMode ? null : null,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDarkMode ? Colors.red[900]!.withOpacity(0.3) : Colors.white, width: 4),
                  boxShadow: isDarkMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          )
                        ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: backgroundImage,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _isLoading ? null : _changeProfilePicture,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : Icon(Icons.add, color: primaryColor, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _user?.displayName ?? 'No Name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? 'No Email',
            style: TextStyle(fontSize: 14, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      {required BuildContext context, required String title, required bool isDarkMode, required Color surfaceColor, required Color primaryColor, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
            : [
                BoxShadow(
                  color: Colors.red.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 4),
            child: Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[200], height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) => items[index],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, Color iconBgColor, Color iconColor, String title, bool isDarkMode, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode ? iconColor.withOpacity(0.1) : iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, Color primaryLightColor, Color primaryColor, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _logout,
        style: TextButton.styleFrom(
          backgroundColor: isDarkMode ? primaryColor.withOpacity(0.1) : primaryLightColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
