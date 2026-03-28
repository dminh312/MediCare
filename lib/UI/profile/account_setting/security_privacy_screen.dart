import 'package:flutter/material.dart';
import 'package:medicare/UI/profile/account_setting/change_password_screen.dart';
import 'package:medicare/UI/profile/account_setting/data_sharing.dart';
import 'package:medicare/UI/share/pp.dart';
import 'package:medicare/UI/share/tos.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _isTwoFactorEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final surfaceColor = isDarkMode ? const Color(0xff1E293B) : Colors.white;
    final Color borderColor = isDarkMode ? Colors.white10 : Colors.red.shade50;
    final Color iconBackgroundColor = isDarkMode ? Colors.red.shade900.withAlpha(51) : Colors.red.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtleTextColor = isDarkMode ? Colors.grey[500] : Colors.grey[600];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Security & Privacy',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans'
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // To balance the leading icon button
        ],
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Container(
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
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.lock_open,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                      },
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDivider(borderColor),
                    _buildTwoFactorAuthItem(
                      icon: Icons.verified_user,
                      title: 'Two-Factor Authentication',
                      value: _isTwoFactorEnabled,
                      onChanged: (value) => setState(() => _isTwoFactorEnabled = value),
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDivider(borderColor),
                    _buildSettingsItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Data Sharing Permissions',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DataSharingScreen()));
                      },
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDivider(borderColor),
                    _buildSettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDivider(borderColor),
                    _buildSettingsItem(
                      icon: Icons.assignment_outlined,
                      title: 'Terms of Service',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen(isReadOnly: true)));
                      },
                      iconBackgroundColor: iconBackgroundColor,
                      primaryColor: primaryColor,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Text(
                  'ACCOUNT SECURITY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  children: [
                    Text(
                      'Logout from all devices where your account is currently signed in. This will end all active sessions.',
                      style: TextStyle(
                        color: subtleTextColor,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Logout from all devices'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Plus Jakarta Sans'),
                        elevation: 4,
                        shadowColor: primaryColor.withAlpha(64),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              const SizedBox(height: 48),

              // Footer Text
              Text(
                'Your health data is protected with 256-bit encryption.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtleTextColor, fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
              ).animate().fade(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconBackgroundColor,
    required Color primaryColor,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
              Icon(Icons.chevron_right, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTwoFactorAuthItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconBackgroundColor,
    required Color primaryColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
              if (states.contains(MaterialState.selected)) {
                return primaryColor;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, color: color, indent: 76);
  }
}
