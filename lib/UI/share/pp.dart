import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool isReadOnly;

  const PrivacyPolicyScreen({super.key, this.isReadOnly = true});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const primaryColor = Color(0xFFea2a33);
    final backgroundColor = isDarkMode
        ? const Color(0xFF1a0f0f)
        : const Color(0xFFfcfaf9);
    final surfaceColor = isDarkMode ? const Color(0xFF2a1d1d) : Colors.white;
    final textColor = isDarkMode
        ? Colors.white
        : const Color(0xFF0f172a); // slate-900
    final secondaryTextColor = isDarkMode
        ? const Color(0xFFcbd5e1)
        : const Color(0xFF475569); // slate-300 / slate-600
    final dividerColor = isDarkMode
        ? const Color(0xFF1e293b)
        : const Color(0xFFf1f5f9); // slate-800 / slate-100

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: (isDarkMode ? backgroundColor : Colors.white)
            .withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: textColor,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: dividerColor, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 44,
                  color: primaryColor,
                ),
              ),

              // Title
              Text(
                'Our Commitment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              // Date Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? surfaceColor
                      : const Color(0xFFf1f5f9), // slate-100
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Last updated: October 24, 2023',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? const Color(0xFF94a3b8)
                        : const Color(0xFF64748b), // slate-400 / slate-500
                  ),
                ),
              ),

              // Description
              Text(
                'At MediCare+, your privacy is the cornerstone of our trust. This document outlines our transparent approach to how we handle your personal health journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 40),

              // Sections
              _buildSection(
                number: '1',
                title: 'Data Collection',
                content:
                    'We collect information you provide directly to us, including your name, email address, date of birth, and health metrics such as weight, height, and activity levels. We may also sync data from integrated health devices (like Samsung Health or wearable trackers) if you grant explicit permission, We only access health data after you provide explicit consent via system permissions.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 32),

              _buildSection(
                number: '2',
                title: 'How We Use Your Data',
                content:
                    'We integrate with trusted platforms such as Health Connect to securely access health data with user authorization, your data is strictly used to provide personalized health insights, track your long-term progress, and offer tailored wellness recommendations. We process anonymized, aggregated data to improve our diagnostic algorithms and app performance.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 32),

              _buildSection(
                number: '3',
                title: 'Data Security',
                content:
                    'We use industry-standard security measures to protect your data, including encryption in transit and secure cloud storage with access control.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 32),

              _buildSection(
                number: '4',
                title: 'Third-party Sharing',
                content:
                    'We never sell your personal or health data to third-party advertisers. We may share data with verified service providers only when necessary to perform core app functions, and always under legally binding confidentiality agreements.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 32),

              _buildSection(
                number: '5',
                title: 'Data Transparency',
                content:
                    'We are committed to transparency in how your data is used. You can view all collected health data directly within the app.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 32),

              _buildSection(
                number: '6',
                title: 'Your Rights',
                content:
                    'You maintain full ownership of your data. You have the right to withdraw consent at any time, access, correct, or delete your health profile at any time. Upon account deletion, all personal data is permanently purged from our primary servers and backups within a 30-day window.',
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 48),

              // Disclaimer Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? surfaceColor
                      : const Color(0xFFf8fafc), // slate-50
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Text(
                  'By continuing to use MediCare+, you acknowledge that you have read and understood this Privacy Policy. We regularly update this document to reflect new safety standards and will notify you of any material changes.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode
                        ? const Color(0xFF94a3b8)
                        : const Color(0xFF64748b),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isReadOnly ? 'I Understand' : 'Accept and Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
