import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initialization or initialization logic here
    // Example: Navigate to next screen after 3 seconds
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/login'); 
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? const [Color(0xFF020617), Color(0xFF0F172A)]
                : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // New App Logo
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate()
               .fade(duration: 800.ms, curve: Curves.easeOut)
               .scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              // App Name with high-end typography
              Text(
                'MediCare',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ).animate()
               .fade(delay: 400.ms, duration: 800.ms)
               .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
               
              const Spacer(),
              
              // Slogan & Loading Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                        strokeWidth: 2.5,
                      ),
                    ).animate().fade(delay: 1000.ms, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Your Health, Our Priority',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.5,
                      ),
                    ).animate()
                     .fade(delay: 1200.ms, duration: 800.ms)
                     .slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOut),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
