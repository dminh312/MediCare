import 'dart:ui';
import 'package:flutter/material.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode, surfaceColor, borderColor),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _buildRecordItem(
            context,
            icon: Icons.description,
            title: 'Medical Reports',
            subtitle: 'Last update: 2 days ago',
            iconColor: primaryColor,
            iconBgColor: isDarkMode ? primaryColor.withAlpha(51) : const Color(0xFFffebee),
          ),
          const SizedBox(height: 16),
          _buildRecordItem(
            context,
            icon: Icons.vaccines,
            title: 'Vaccinations',
            subtitle: 'Next due: Oct 24, 2024',
            iconColor: Colors.blue.shade500,
            iconBgColor: isDarkMode ? Colors.blue.shade900.withAlpha(102) : Colors.blue.shade50,
          ),
          const SizedBox(height: 16),
          _buildRecordItem(
            context,
            icon: Icons.biotech,
            title: 'Lab Results',
            subtitle: '3 new results available',
            iconColor: Colors.purple.shade500,
            iconBgColor: isDarkMode ? Colors.purple.shade900.withAlpha(102) : Colors.purple.shade50,
          ),
          const SizedBox(height: 16),
          _buildRecordItem(
            context,
            icon: Icons.medication,
            title: 'Prescriptions',
            subtitle: 'Last refill: 1 week ago',
            iconColor: Colors.orange.shade500,
            iconBgColor: isDarkMode ? Colors.orange.shade900.withAlpha(102) : Colors.orange.shade50,
          ),
          const SizedBox(height: 32),
          _buildUploadPlaceholder(isDarkMode, primaryColor),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Upload New Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        icon: const Icon(Icons.add),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode, Color surfaceColor, Color borderColor) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withOpacity(0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Health Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildRecordItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color iconColor, Color? iconBgColor}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withOpacity(0.05),
      elevation: 1,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        border: Border.all(color: isDarkMode ? primaryColor.withAlpha(51) : Colors.red.shade100, width: 2, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload, color: isDarkMode ? primaryColor.withAlpha(77) : Colors.red[200], size: 40),
          const SizedBox(height: 8),
          Text(
            'Keep your records organized. All uploads are encrypted and secure.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }
}
