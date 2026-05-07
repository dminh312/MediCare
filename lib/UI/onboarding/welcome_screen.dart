import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicare/UI/onboarding/permission_explanation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const Color _backgroundColor = Color(0xFFFFFBFB);
  static const Color _primaryColor = Color(0xFFEA2A33);
  static const Color _textColor = Color(0xFF111827);
  static const Color _subtleTextColor = Color(0xFF64748B);

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.health_and_safety,
      'title': 'Welcome to\nMediCare+',
      'description':
          'Your ultimate companion for tracking health, managing medications, and living better.',
      'color': const Color(0xFFea2a33),
    },
    {
      'icon': Icons.monitor_heart,
      'title': 'Track Your Health',
      'description':
          'Monitor your daily steps, heart rate, and sleep quality seamlessly.',
      'color': const Color(0xFFea2a33),
    },
    {
      'icon': Icons.medical_services,
      'title': 'Manage Medications',
      'description': 'Set smart reminders and never miss your dose again.',
      'color': const Color(0xFFea2a33),
    },
  ];

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
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (data['color'] as Color).withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            data['icon'],
                            size: 60,
                            color: data['color'],
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: index == 0 ? _primaryColor : _textColor,
                            letterSpacing: 0,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            data['description'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: _subtleTextColor,
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
                      ],
                    ),
                  ),
                ),
              );
            },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PermissionExplanationScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFea2a33),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: _primaryColor.withValues(alpha: 0.35),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
