import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicare/UI/onboarding/permission_toggle_screen.dart';

class PermissionExplanationScreen extends StatelessWidget {
  const PermissionExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1e293b);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF94a3b8)
        : const Color(0xFF64748b);
    const primaryColor = Color(0xFFea2a33);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1a0f0f)
          : const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: primaryColor,
                  size: 32,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(),
              const SizedBox(height: 24),
              Text(
                'Your Data, Your Control',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 12),
              Text(
                'MediCare+ needs certain permissions to give you the most accurate health insights. We only use this data to calculate your personalized metrics locally on your device.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: subtleTextColor,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(),
              const SizedBox(height: 40),

              _buildPermissionInfo(
                icon: Icons.monitor_heart_outlined,
                title: 'Health Connect',
                description:
                    'To seamlessly sync your activity, sleep, and heart rate data from other apps and wearables.',
                delay: 400,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildPermissionInfo(
                icon: Icons.location_on_outlined,
                title: 'Location Access',
                description:
                    'To help you find nearby pharmacies, hospitals, and clinics effortlessly.',
                delay: 450,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildPermissionInfo(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                description:
                    'To remind you to take your medications and complete daily health tracks.',
                delay: 500,
                isDarkMode: isDarkMode,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermissionToggleScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionInfo({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
    required bool isDarkMode,
  }) {
    final surfaceColor = isDarkMode ? const Color(0xFF2a1d1d) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1e293b);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF94a3b8)
        : const Color(0xFF64748b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Icon(icon, color: const Color(0xFFea2a33), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: subtleTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX();
  }
}
