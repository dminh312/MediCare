import 'package:flutter/material.dart';
import 'package:medicare/UI/chatbot/chatbot_screen.dart';
import 'package:medicare/UI/home/home_screen.dart';
import 'package:medicare/UI/meds/meds_screen.dart';
import 'package:medicare/UI/profile/profile_screen.dart';
import 'package:medicare/UI/share/bottom_navigation.dart';
import 'package:medicare/UI/track/track_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (context) => const _HomeContent());
  }
}

// Main view that holds the scaffold and bottom navigation
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _selectedIndex = 0;
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _trackKey = GlobalKey();
  final GlobalKey _medsKey = GlobalKey();

  // List of pages to be displayed
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TrackScreen(),
    const MedsScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('has_seen_walkthrough') ?? false;
      if (!seen && mounted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            ShowCaseWidget.of(context).startShowCase([_trackKey, _medsKey, _fabKey]);
            prefs.setBool('has_seen_walkthrough', true);
          }
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFff5252);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: Showcase(
        key: _fabKey,
        description:
            'New! Chat with our intelligent health assistant for instant answers.',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          backgroundColor: primaryColor,
          shape: const CircleBorder(),
          elevation: 4.0,
          child: Icon(
            Icons.medical_services,
            color: isDarkMode ? Colors.black : Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        trackKey: _trackKey,
        medsKey: _medsKey,
      ),
    );
  }
}
