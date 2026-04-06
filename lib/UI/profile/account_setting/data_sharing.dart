import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicare/logic/services/health_services.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';

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
  
  bool _isHealthConnectConnected = false;
  bool _isSyncingHealthConnect = false;

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
      _isHealthConnectConnected = 
          prefs.getBool('health_connect_connected') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-using the color scheme from previous screens
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final surfaceColor = isDarkMode ? const Color(0xff1E293B) : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.white10
        : Colors.red.shade50;
    final Color iconBackgroundColor = isDarkMode
        ? Colors.red.shade900.withAlpha(51)
        : Colors.red.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[500] : Colors.grey[600];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
              ? [const Color(0xFF020617), const Color(0xFF0F172A)] 
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        // AppBar styling similar to other screens
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 28,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Data Sharing',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
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
                    fontSize: 14,
                    color: subtleTextColor,
                    fontFamily: 'Plus Jakarta Sans',
                    height: 1.6,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 24),

              // Sharing Options Card
              _buildCard(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
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
                      isDarkMode: isDarkMode,
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
                      isDarkMode: isDarkMode,
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
                      isDarkMode: isDarkMode,
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
                      isDarkMode: isDarkMode,
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
                      isDarkMode: isDarkMode,
                      isLast: true,
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 40),

              // Connected Apps Section
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Text(
                  'CONNECTED APPS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              _buildCard(
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
                child: Column(
                  children: [
                    _buildConnectedApp(
                      icon: Icons.monitor_heart, 
                      appName: 'Health Connect',
                      status: _isHealthConnectConnected ? 'Connected' : 'Not connected',
                      iconColor: Colors.teal.shade500,
                      iconBg: Colors.teal.shade50,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      isSyncing: _isSyncingHealthConnect,
                      onManage: () async {
                        setState(() => _isSyncingHealthConnect = true);
                        bool success = await HealthService().syncHealthDataToFirebase();
                        if (mounted) {
                          setState(() {
                            _isSyncingHealthConnect = false;
                            if (success) _isHealthConnectConnected = true;
                          });
                          if (success) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('health_connect_connected', true);
                            Provider.of<HealthDataViewModel>(context, listen: false).loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Successfully synced with Health Connect')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to connect or sync with Health Connect')),
                            );
                          }
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 40),

              // Footer Text
              Text(
                'Third-party apps are subject to their own privacy policies.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtleTextColor, fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
              ).animate().fade(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }

  // Helper to build the main container card
  Widget _buildCard({
    required Color surfaceColor,
    required Color borderColor,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))
          else
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 8)),
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
    required bool isDarkMode,
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87, fontFamily: 'Plus Jakarta Sans'),
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
    bool isSyncing = false,
    VoidCallback? onManage,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[500] : Colors.grey[600], fontFamily: 'Plus Jakarta Sans'),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isSyncing ? null : onManage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: manageButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSyncing 
              ? SizedBox(
                  width: 12, 
                  height: 12, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)
                )
              : Text(
                  'Connect',
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
