import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/UI/login/login_screen.dart';

class AppOnboardingScreen extends StatefulWidget {
  const AppOnboardingScreen({super.key});

  @override
  State<AppOnboardingScreen> createState() => _AppOnboardingScreenState();
}

class _AppOnboardingScreenState extends State<AppOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const Color _backgroundColor = Color(0xFFFFFBFB);
  static const Color _primaryColor = Color(0xFFEA2A33);
  static const Color _textColor = Color(0xFF111827);
  static const Color _subtleTextColor = Color(0xFF64748B);

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Your Health,\nOur Priority',
      'subtitle':
          'Manage your health records securely and effortlessly with AI.',
      'icon': Icons.health_and_safety_rounded,
      'color': const Color(0xFFFF5252),
    },
    {
      'title': 'Smart Trajectory',
      'subtitle':
          'Track your steps, heart rate, and sleep automatically with Health Connect.',
      'icon': Icons.show_chart_rounded,
      'color': const Color(0xFF5DDbbc),
    },
    {
      'title': 'Absolute Privacy',
      'subtitle':
          'Your data stays encrypted. You have complete control over what is shared.',
      'icon': Icons.shield_rounded,
      'color': const Color(0xFFffb4ab),
    },
    {
      'title': 'Welcome to MediCare+',
      'subtitle': 'Let\'s start your journey to a healthier life!',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFffb4ab),
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_app_onboarding', true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (data['color'] as Color).withValues(alpha: 0.12),
                border: Border.all(
                  color: (data['color'] as Color).withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: Icon(
                  data['icon'] as IconData,
                  size: 100,
                  color: data['color'] as Color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: _textColor,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data['subtitle'] as String,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _subtleTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots Indicator
          Row(
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? _primaryColor
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Action Button
          GestureDetector(
            onTap: () {
              if (_currentPage == _pages.length - 1) {
                _finishOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryColor, Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
