import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/logic/services/notification_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool _pushNotifications = true;
  bool _medicationReminders = true;
  bool _healthTips = true;
  bool _dailyGoalReminders = false;
  bool _activityAlerts = true;
  bool _quietHoursEnabled = false;

  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _medicationReminders = prefs.getBool('medicationReminders') ?? true;
      _healthTips = prefs.getBool('healthTips') ?? true;
      _dailyGoalReminders = prefs.getBool('dailyGoalReminders') ?? false;
      _activityAlerts = prefs.getBool('activityAlerts') ?? true;
      _quietHoursEnabled = prefs.getBool('quietHoursEnabled') ?? false;
      
      int startHour = prefs.getInt('quietStartHour') ?? 22;
      int startMinute = prefs.getInt('quietStartMinute') ?? 0;
      int endHour = prefs.getInt('quietEndHour') ?? 7;
      int endMinute = prefs.getInt('quietEndMinute') ?? 0;
      
      _startTime = TimeOfDay(hour: startHour, minute: startMinute);
      _endTime = TimeOfDay(hour: endHour, minute: endMinute);
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final surfaceColor = isDarkMode ? const Color(0xff1E293B) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.white10 : Colors.red.shade50;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: Center(
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.arrow_back, color: isDarkMode ? Colors.grey[200] : Colors.grey[700], size: 20),
            ),
          ),
        ),
        title: Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [const Color(0xFF020617), const Color(0xFF0F172A)] 
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildMasterToggle(surfaceColor, borderColor, primaryColor, isDarkMode)
                .animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOut),
            const SizedBox(height: 24),
            _buildAlertCategories(surfaceColor, borderColor, primaryColor, isDarkMode)
                .animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOut),
            const SizedBox(height: 32),
            _buildQuietHours(surfaceColor, borderColor, primaryColor, isDarkMode)
                .animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildCard(
      surfaceColor,
      borderColor,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? primaryColor.withAlpha(51) : const Color(0xFFffebee),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_active, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.grey[100] : Colors.grey[800])),
                const SizedBox(height: 2),
                Text('Master alert switch', style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
              ],
            ),
          ),
          _buildIOSStyleToggle(value: _pushNotifications, onChanged: (val) {
            setState(() => _pushNotifications = val);
            _saveSetting('pushNotifications', val);
            if (val) {
              NotificationService().init(); // Re-init to ensure permissions
            }
          }),
        ],
      ),
    );
  }

  Widget _buildAlertCategories(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildCard(
      surfaceColor,
      borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('ALERT CATEGORIES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.5)),
          ),
          _buildCategoryItem('Medication Reminders', Icons.medical_services_outlined, _medicationReminders, (val) {
            setState(() => _medicationReminders = val);
            _saveSetting('medicationReminders', val);
          }, isDarkMode),
          _buildDivider(isDarkMode),
          _buildCategoryItem('Health Tips & Insights', Icons.lightbulb_outline, _healthTips, (val) {
            setState(() => _healthTips = val);
            _saveSetting('healthTips', val);
          }, isDarkMode),
           _buildDivider(isDarkMode),
          _buildCategoryItem('Daily Goal Reminders', Icons.flag_outlined, _dailyGoalReminders, (val) {
            setState(() => _dailyGoalReminders = val);
            _saveSetting('dailyGoalReminders', val);
          }, isDarkMode),
           _buildDivider(isDarkMode),
          _buildCategoryItem('Activity Alerts', Icons.bolt_outlined, _activityAlerts, (val) {
            setState(() => _activityAlerts = val);
            _saveSetting('activityAlerts', val);
          }, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool value, ValueChanged<bool> onChanged, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: isDarkMode ? Colors.grey[400] : Colors.grey[500], size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[200]: Colors.grey[800]))),
          Transform.scale(scale: 0.9, child: _buildIOSStyleToggle(value: value, onChanged: onChanged)),
        ],
      ),
    );
  }

  Widget _buildQuietHours(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildCard(
      surfaceColor,
      borderColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('QUIET HOURS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.5, fontFamily: 'Plus Jakarta Sans')),
                 Transform.scale(scale: 0.75, child: _buildIOSStyleToggle(value: _quietHoursEnabled, onChanged: (val) {
                   setState(() => _quietHoursEnabled = val);
                   _saveSetting('quietHoursEnabled', val);
                 })),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _quietHoursEnabled
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildTimePicker('Start Time', _startTime, (time) {
                              setState(() => _startTime = time);
                              _saveSetting('quietStartHour', time.hour);
                              _saveSetting('quietStartMinute', time.minute);
                            }, isDarkMode)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTimePicker('End Time', _endTime, (time) {
                              setState(() => _endTime = time);
                              _saveSetting('quietEndHour', time.hour);
                              _saveSetting('quietEndMinute', time.minute);
                            }, isDarkMode)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All notifications except emergency medication alerts will be silenced during this period.',
                          style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[500] : Colors.grey[600], fontStyle: FontStyle.italic, height: 1.4, fontFamily: 'Plus Jakarta Sans'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onTimeChanged, bool isDarkMode) {
  final timeSurface = isDarkMode ? Colors.grey[800] : Colors.grey[100];
  final timeBorder = isDarkMode ? Colors.grey[700] : Colors.grey[200];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(label, style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
      ),
      GestureDetector(
        onTap: () async {
          final newTime = await showTimePicker(context: context, initialTime: time);
          if (newTime != null) {
            onTimeChanged(newTime);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: timeSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: timeBorder!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(time.format(context), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[200] : Colors.grey[700]))],
          ),
        ),
      ),
    ],
  );
}


  Widget _buildCard(Color surfaceColor, Color borderColor, {required Widget child, EdgeInsets? padding}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
  
  Widget _buildIOSStyleToggle({required bool value, required ValueChanged<bool> onChanged}) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xffff5252),
    );
  }

  Widget _buildDivider(bool isDarkMode) => Divider(height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[100], indent: 16, endIndent: 16);
}
