import 'dart:ui';
import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withAlpha(204),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSearchBar(surfaceColor, primaryColor),
          const SizedBox(height: 32),
          _buildFaqSection(primaryColor, surfaceColor, borderColor),
          const SizedBox(height: 32),
          _buildContactSection(primaryColor, surfaceColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color surfaceColor, Color primaryColor) {
    return TextField(
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search for help...',
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withAlpha(128), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFaqSection(Color primaryColor, Color surfaceColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 8),
        _buildFaqItem('Account & Login', Icons.account_circle, primaryColor, surfaceColor, borderColor),
        const SizedBox(height: 12),
        _buildFaqItem('Medication Tracking', Icons.medication, primaryColor, surfaceColor, borderColor),
        const SizedBox(height: 12),
        _buildFaqItem('Privacy & Data', Icons.verified_user, primaryColor, surfaceColor, borderColor),
        const SizedBox(height: 12),
        _buildFaqItem('AI Chatbot Tips', Icons.smart_toy, primaryColor, surfaceColor, borderColor),
      ],
    );
  }

  Widget _buildFaqItem(String title, IconData icon, Color primaryColor, Color surfaceColor, Color borderColor) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withAlpha(13),
      elevation: 1,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             border: Border.all(color: borderColor)
           ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              Icon(Icons.expand_more, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(Color primaryColor, Color surfaceColor, Color borderColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text('STILL NEED HELP?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 8),
        _buildContactOption(
          title: 'Contact Support',
          subtitle: 'Typically replies within 24 hours',
          icon: Icons.mail,
          iconColor: primaryColor,
          iconBgColor: isDarkMode ? primaryColor.withAlpha(51) : const Color(0xFFffebee),
          surfaceColor: surfaceColor,
          borderColor: borderColor,
        ),
        const SizedBox(height: 12),
        _buildContactOption(
          title: 'Live Chat',
          subtitle: 'Speak with an agent now',
          icon: Icons.chat_bubble,
          iconColor: Colors.pink.shade400,
          iconBgColor: isDarkMode ? Colors.pink.withAlpha(51) : Colors.pink[50],
          surfaceColor: surfaceColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? iconBgColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withAlpha(13),
      elevation: 1,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor)
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
