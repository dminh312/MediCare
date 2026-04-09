import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final bool isReadOnly;

  const TermsOfServiceScreen({super.key, this.isReadOnly = true});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFea2a33);
    final backgroundColor = isDarkMode
        ? const Color(0xFF1a0f0f)
        : const Color(0xFFf8f6f6);
    final surfaceColor = isDarkMode ? const Color(0xFF2a1d1d) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1e293b);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF94a3b8)
        : const Color(0xFF64748b);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: (isDarkMode ? const Color(0xFF1a0f0f) : Colors.white)
            .withAlpha(230),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryColor, textColor, subtleTextColor),
            const SizedBox(height: 40),
            _buildSection(
              number: '01',
              title: 'Acceptance of Terms',
              content:
                  'By accessing or using MediCare+, you agree to be bound by these terms. If you disagree with any part of the terms, then you may not access the service. We reserve the right to modify these terms at any time. We will notify you of any changes by posting the new terms on this page.',
              primaryColor: primaryColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),
            const SizedBox(height: 40),
            _buildUseOfServiceSection(
              primaryColor,
              textColor,
              subtleTextColor,
              surfaceColor,
              isDarkMode,
            ),
            const SizedBox(height: 40),
            _buildPrivacyPolicySection(
              primaryColor,
              textColor,
              subtleTextColor,
              surfaceColor,
              isDarkMode,
            ),
            const SizedBox(height: 40),
            _buildUserConductSection(
              primaryColor,
              textColor,
              subtleTextColor,
              surfaceColor,
              isDarkMode,
            ),
            const SizedBox(height: 40),
            _buildSection(
              number: '05',
              title: 'Limitation of Liability',
              content:
                  'In no event shall MediCare+, nor its directors, employees, or affiliates, be liable for any indirect, incidental, special, or consequential damages resulting from your access to or use of the service. We provide the application "as is" without warranty of any kind.',
              primaryColor: primaryColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),
            const SizedBox(height: 40),
            _buildContactUsSection(primaryColor, textColor, subtleTextColor),
            const SizedBox(height: 40),
            if (!widget.isReadOnly)
              _buildFooter(
                context,
                primaryColor,
                surfaceColor,
                subtleTextColor,
                isDarkMode,
              ),
          ].animate(interval: 50.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildHeader(
    Color primaryColor,
    Color textColor,
    Color subtleTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: const Text(
            'LEGAL NOTICE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: primaryColor.withAlpha(26),
          labelStyle: TextStyle(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: primaryColor.withAlpha(51)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Terms and Conditions',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: subtleTextColor),
            const SizedBox(width: 8),
            Text(
              'Last updated: October 24, 2023',
              style: TextStyle(
                fontSize: 12,
                color: subtleTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Please read these terms and conditions carefully before using the MediCare+ application. These terms constitute a legally binding agreement between you and MediCare+.',
          style: TextStyle(fontSize: 16, color: subtleTextColor, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    required Color primaryColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: TextStyle(fontSize: 15, color: subtleTextColor, height: 1.7),
        ),
      ],
    );
  }

  Widget _buildUseOfServiceSection(
    Color primaryColor,
    Color textColor,
    Color subtleTextColor,
    Color surfaceColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '02',
              style: TextStyle(
                color: Color(0xFFea2a33),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Use of Service',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'MediCare+ is designed for personal health tracking. You are responsible for maintaining the confidentiality of your account and password. The application is not a substitute for professional medical advice, diagnosis, or treatment.',
          style: TextStyle(fontSize: 15, color: subtleTextColor, height: 1.7),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(13),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border(left: BorderSide(color: primaryColor, width: 4)),
          ),
          child: Text(
            '"Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition."',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildListItem(
          primaryColor,
          subtleTextColor,
          'Maintain absolute account security and password confidentiality.',
        ),
        _buildListItem(
          primaryColor,
          subtleTextColor,
          'Provide accurate, current, and complete information.',
        ),
        _buildListItem(
          primaryColor,
          subtleTextColor,
          'Respect all service limitations and intended use cases.',
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicySection(
    Color primaryColor,
    Color textColor,
    Color subtleTextColor,
    Color surfaceColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '03',
              style: TextStyle(
                color: Color(0xFFea2a33),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Your privacy is paramount. MediCare+ respects your privacy regarding any information we may collect across our application. We only ask for personal information when it is vital to providing the service.',
          style: TextStyle(fontSize: 15, color: subtleTextColor, height: 1.7),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? surfaceColor : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'SECURITY STANDARDS',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'We use industry-standard AES-256 encryption to protect your sensitive health data. We never sell your personal information to third-party data brokers or advertisers.',
                style: TextStyle(
                  color: subtleTextColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserConductSection(
    Color primaryColor,
    Color textColor,
    Color subtleTextColor,
    Color surfaceColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '04',
              style: TextStyle(
                color: Color(0xFFea2a33),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'User Conduct',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'You agree not to use the application for any purpose that is prohibited by these terms. Prohibited activities include but are not limited to:',
          style: TextStyle(fontSize: 15, color: subtleTextColor, height: 1.7),
        ),
        const SizedBox(height: 24),
        _buildConductItem(
          surfaceColor,
          isDarkMode,
          Icons.gavel,
          'Illegal purposes or fraudulent activity',
          subtleTextColor,
        ),
        const SizedBox(height: 12),
        _buildConductItem(
          surfaceColor,
          isDarkMode,
          Icons.lock_open,
          'Unauthorized system access attempts',
          subtleTextColor,
        ),
        const SizedBox(height: 12),
        _buildConductItem(
          surfaceColor,
          isDarkMode,
          Icons.bug_report,
          'Uploading viruses or malicious code',
          subtleTextColor,
        ),
      ],
    );
  }

  Widget _buildContactUsSection(
    Color primaryColor,
    Color textColor,
    Color subtleTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '06',
              style: TextStyle(
                color: Color(0xFFea2a33),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'If you have any questions about these Terms, please reach out to our legal department or support team.',
          style: TextStyle(fontSize: 15, color: subtleTextColor, height: 1.7),
        ),
        const SizedBox(height: 24),
        _buildContactButton(
          primaryColor,
          Icons.mail,
          'medicare.support@gmail.com',
        ),
        const SizedBox(height: 12),
        _buildContactButton(
          primaryColor,
          Icons.language,
          'Help Center & Documentation',
        ),
      ],
    );
  }

  Widget _buildListItem(
    Color primaryColor,
    Color subtleTextColor,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: subtleTextColor, height: 1.6, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildConductItem(
    Color surfaceColor,
    bool isDarkMode,
    IconData icon,
    String text,
    Color subtleTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? surfaceColor : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: subtleTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(Color primaryColor, IconData icon, String text) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: primaryColor),
      label: Text(
        text,
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        backgroundColor: primaryColor.withAlpha(13),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    Color primaryColor,
    Color surfaceColor,
    Color subtleTextColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? surfaceColor : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _isChecked ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isChecked ? primaryColor : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By proceeding, you acknowledge that you have read and understood the full Terms of Service.',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtleTextColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isChecked ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _isChecked ? 8 : 0,
            shadowColor: primaryColor.withAlpha(102),
          ),
          child: Text(
            'Accept and Continue',
            style: TextStyle(
              color: _isChecked 
                  ? Colors.white 
                  : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Version 0.0.1 • MediCare+ Legal',
          style: TextStyle(
            fontSize: 11,
            color: subtleTextColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
