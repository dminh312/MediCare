import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFff5252);
    const primaryDarkColor = Color(0xFFd32f2f);
    const primaryLightColor = Color(0xFFffebee);
    final surfaceDarkColor = const Color(0xFF2d1f1f);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      color: isDarkMode ? surfaceDarkColor : Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 20,
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              Icons.home,
              Icons.home_outlined,
              "Home",
              0,
              primaryColor,
              primaryDarkColor,
              primaryLightColor,
              isDarkMode,
            ),
            _buildNavItem(
              Icons.monitor_heart,
              Icons.monitor_heart,
              "Track",
              1,
              primaryColor,
              primaryDarkColor,
              primaryLightColor,
              isDarkMode,
            ),
            _buildChatbotItem(),
            _buildNavItem(
              Icons.medication,
              Icons.medication_outlined,
              "Meds",
              2,
              primaryColor,
              primaryDarkColor,
              primaryLightColor,
              isDarkMode,
            ),
            _buildNavItem(
              Icons.person,
              Icons.person_outline,
              "Profile",
              3,
              primaryColor,
              primaryDarkColor,
              primaryLightColor,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
    Color primaryColor,
    Color primaryDarkColor,
    Color primaryLightColor,
    bool isDarkMode,
  ) {
    final isSelected = widget.selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => widget.onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                          ? primaryColor.withOpacity(0.3)
                          : primaryLightColor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected
                    ? (isDarkMode ? primaryLightColor : primaryDarkColor)
                    : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDarkMode ? primaryLightColor : primaryDarkColor)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotItem() {
    return Expanded(
      child: InkWell(
        onTap: () {},
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 36,
            ), // Placeholder for icon area and to push text down
            Text(
              "Chatbot",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
