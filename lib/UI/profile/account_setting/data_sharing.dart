import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSharingScreen extends StatefulWidget {
  const DataSharingScreen({super.key});

  @override
  State<DataSharingScreen> createState() => _DataSharingScreenState();
}

class _DataSharingScreenState extends State<DataSharingScreen> {
  // State for the switches
  bool _healthStatsSharing = true;
  bool _activityDataSharing = true;
  bool _medicationHistorySharing = false;
  bool _anonymizedResearchSharing = true;
  bool _chatbotHistorySharing = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatbotHistorySharing =
          prefs.getBool('chatbot_save_history_preference') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-using the color scheme from previous screens
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode
        ? const Color(0xff1a1111)
        : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.red.shade900.withAlpha(26)
        : Colors.red.shade50;
    final Color iconBackgroundColor = isDarkMode
        ? Colors.red.shade900.withAlpha(51)
        : Colors.red.shade50;
    final textColor = isDarkMode ? Colors.grey[100] : Colors.grey[900];
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // AppBar styling similar to other screens
        backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withAlpha(
          204,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 28,
            color: isDarkMode ? Colors.grey[200] : Colors.grey[700],
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Data Sharing',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        actions: [const SizedBox(width: 48)],
        shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Description Text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Control how your health data is shared with our trusted third-party partners and medical research institutions to improve your healthcare experience and support medical breakthroughs.',
                  style: TextStyle(
                    fontSize: 15,
                    color: subtleTextColor,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sharing Options Card
              _buildCard(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                child: Column(
                  children: [
                    _buildSharingOption(
                      icon: Icons.analytics,
                      title: 'Health Statistics sharing',
                      value: _healthStatsSharing,
                      onChanged: (val) =>
                          setState(() => _healthStatsSharing = val),
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                    ),
                    _buildDivider(borderColor),
                    _buildSharingOption(
                      icon: Icons.fitness_center,
                      title: 'Activity data sharing',
                      value: _activityDataSharing,
                      onChanged: (val) =>
                          setState(() => _activityDataSharing = val),
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                    ),
                    _buildDivider(borderColor),
                    _buildSharingOption(
                      icon: Icons.medication,
                      title: 'Medication history sharing',
                      value: _medicationHistorySharing,
                      onChanged: (val) =>
                          setState(() => _medicationHistorySharing = val),
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                    ),
                    _buildDivider(borderColor),
                    _buildSharingOption(
                      icon: Icons.chat,
                      title: 'Medicare+ AI Chatbot History',
                      value: _chatbotHistorySharing,
                      onChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        setState(() => _chatbotHistorySharing = val);
                        await prefs.setBool(
                          'chatbot_save_history_preference',
                          val,
                        );
                      },
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                    ),
                    _buildDivider(borderColor),
                    _buildSharingOption(
                      icon: Icons.science,
                      title: 'Anonymized research data',
                      value: _anonymizedResearchSharing,
                      onChanged: (val) =>
                          setState(() => _anonymizedResearchSharing = val),
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Connected Apps Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Text(
                  'CONNECTED APPS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.withAlpha(204),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildCard(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                child: Column(
                  children: [
                    _buildConnectedApp(
                      icon: Icons.bubble_chart, // Placeholder for Google Fit
                      appName: 'Google Fit',
                      status: 'Connected',
                      iconColor: Colors.blue.shade500,
                      iconBg: Colors.blue.shade50,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                    ),
                    _buildDivider(borderColor),
                    _buildConnectedApp(
                      icon: Icons.favorite,
                      appName: 'Apple Health',
                      status: 'Connected',
                      iconColor: primaryColor,
                      iconBg: Colors.grey.shade50,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Footer Text
              Text(
                'Third-party apps are subject to their own privacy policies.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build the main container card
  Widget _buildCard({
    required Color surfaceColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper for sharing option rows
  Widget _buildSharingOption({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconBackgroundColor,
    required Color primaryColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor.withOpacity(0.5),
            thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.selected)) return primaryColor;
              return null;
            }),
          ),
        ],
      ),
    );
  }

  // Helper for connected app rows
  Widget _buildConnectedApp({
    required IconData icon,
    required String appName,
    required String status,
    required Color iconColor,
    required Color iconBg,
    required bool isDarkMode,
    required Color primaryColor,
    bool isLast = false,
  }) {
    final manageButtonBg = isDarkMode
        ? Colors.red.shade900.withAlpha(51)
        : Colors.red.shade50;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: manageButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Manage',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Divider helper
  Widget _buildDivider(Color color) =>
      Divider(height: 1, color: color, indent: 76);
}
