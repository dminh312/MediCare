import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLockSuccessScreen extends StatelessWidget {
  const AppLockSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: Color(0xFFFF5252),
                ).animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 1200.ms, color: Colors.white54),
              ).animate().fade(duration: 400.ms),
              const SizedBox(height: 32),
              const Text(
                'App Locked Successfully',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1111),
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              const Text(
                'Your biometric lock is now active.\nYour data is secure.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF534343),
                  fontFamily: 'Plus Jakarta Sans',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to the settings screen (twice to avoid going back to pin setup)
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.4),
            ],
          ),
        ),
      ),
    );
  }
}
