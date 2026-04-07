import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';
import 'package:medicare/logic/services/notification_service.dart';
import 'package:medicare/UI/onboarding/thank_you_screen.dart';
import 'package:medicare/logic/services/health_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionToggleScreen extends StatefulWidget {
  const PermissionToggleScreen({super.key});

  @override
  State<PermissionToggleScreen> createState() => _PermissionToggleScreenState();
}

class _PermissionToggleScreenState extends State<PermissionToggleScreen> {
  bool _healthConnectEnabled = true;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  void _onAcceptPressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_healthConnectEnabled) {
        bool success = await HealthService().syncHealthDataToFirebase();
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('health_connect_connected', true);
          if (mounted) {
            Provider.of<HealthDataViewModel>(context, listen: false).loadData();
          }
        } else {
          // Sync/Permission failed
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to connect to Health Connect. Please grant permissions and try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return; // Stop navigation
        }
      }

      if (_notificationsEnabled) {
        // Notification permissions are typically requested during initialization or on-demand
        // This acts as a reaffirmation or triggers init if it hasn't somehow
        await Provider.of<NotificationService>(context, listen: false).init();
      }
    } catch (e) {
      debugPrint("Permission error: $e");
    } finally {
      if (mounted && _isLoading) { // _isLoading is false if we returned early
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ThankYouScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1e293b);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF94a3b8)
        : const Color(0xFF64748b);
    const primaryColor = Color(0xFFea2a33);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1a0f0f)
          : const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enable Features',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 12),
              Text(
                'You can review or change these settings later in the app.',
                style: TextStyle(fontSize: 16, color: subtleTextColor),
              ).animate().fadeIn(delay: 100.ms).slideX(),
              const SizedBox(height: 40),

              _buildToggleItem(
                icon: Icons.monitor_heart,
                title: 'Health Connect',
                description: 'Sync steps, sleep & heart rate',
                value: _healthConnectEnabled,
                onChanged: (val) {
                  setState(() => _healthConnectEnabled = val);
                },
                delay: 200,
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20),
              _buildToggleItem(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                description: 'Get medication & health reminders',
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
                delay: 300,
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onAcceptPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required int delay,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final surfaceColor = isDarkMode ? const Color(0xFF2a1d1d) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1e293b);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF94a3b8)
        : const Color(0xFF64748b);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: subtleTextColor),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX();
  }
}
