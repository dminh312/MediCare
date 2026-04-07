import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/main.dart'; // To access AuthWrapper

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  void _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: primaryColor,
                          size: 60,
                        ),
                      ).animate().scale(
                        delay: 200.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Thank You!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                      const SizedBox(height: 16),
                      Text(
                        'You are all set. We look forward to being part of your journey to better health.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: subtleTextColor,
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _finishOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
