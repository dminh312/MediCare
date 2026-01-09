import 'package:flutter/material.dart';
import 'package:medicare/UI/home/home_screen.dart';
import 'package:medicare/UI/meds/meds_screen.dart';
import 'package:medicare/UI/profile/profile_screen.dart';
import 'package:medicare/UI/share/bottom_navigation.dart';
import 'package:medicare/UI/track/track_screen.dart';

// Main view that holds the scaffold and bottom navigation
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // List of pages to be displayed
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TrackPage(),
    const MedsPage(),
    const ProfilePage(),
  ];

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement Chatbot navigation/modal
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        elevation: 4.0,
        child: Icon(Icons.medical_services, color: isDarkMode ? Colors.black : Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
