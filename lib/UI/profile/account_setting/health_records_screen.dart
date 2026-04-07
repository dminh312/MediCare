import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicare/UI/profile/account_setting/record_viewer_screen.dart';
import 'package:medicare/UI/profile/account_setting/upload_record_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final Map<String, IconData> _categoryIcons = {
    'Medical Reports': Icons.description,
    'Vaccinations': Icons.vaccines,
    'Lab Results': Icons.biotech,
    'Prescriptions': Icons.medication,
  };

  final Map<String, MaterialColor> _categoryColors = {
    'Medical Reports': Colors.red,
    'Vaccinations': Colors.blue,
    'Lab Results': Colors.purple,
    'Prescriptions': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode
        ? const Color(0xff1a1111)
        : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.red.shade900.withAlpha(26)
        : Colors.red.shade50;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode, surfaceColor, borderColor),
      body: user == null
          ? const Center(child: Text('Please log in to view health records'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_records')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs.toList() ?? [];

                // Sort locally to avoid Firestore composite index requirement
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime =
                      (aData['uploadedAt'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime =
                      (bData['uploadedAt'] as Timestamp?)?.toDate() ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return bTime.compareTo(aTime); // Descending order
                });

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  children: [
                    if (docs.isEmpty)
                      _buildUploadPlaceholder(isDarkMode, primaryColor)
                    else
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final category =
                            data['category'] as String? ?? 'Medical Reports';
                        final title = data['title'] as String? ?? 'Document';
                        final uploadedAt = (data['uploadedAt'] as Timestamp?)
                            ?.toDate();
                        final dateStr = uploadedAt != null
                            ? DateFormat('MMM d, yyyy').format(uploadedAt)
                            : 'Unknown date';
                        final fileUrl = data['fileUrl'] as String?;

                        // Fallback colors if category doesn't strictly match
                        final iconColor =
                            _categoryColors[category] ?? Colors.grey;
                        final icon =
                            _categoryIcons[category] ?? Icons.insert_drive_file;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildRecordItem(
                            context,
                            docId: doc.id,
                            fileUrl: fileUrl,
                            icon: icon,
                            title: title,
                            subtitle: 'Uploaded: $dateStr',
                            iconColor: iconColor.shade500,
                            iconBgColor: isDarkMode
                                ? iconColor.shade900.withAlpha(102)
                                : iconColor.shade50,
                          ),
                        );
                      }),

                    if (docs.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      _buildUploadPlaceholder(isDarkMode, primaryColor),
                    ],
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadRecordScreen()),
          );
          if (result == true) {
            // Optional: Show success message if not handled inside UploadRecordScreen
          }
        },
        label: const Text(
          'Upload New Record',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    Color surfaceColor,
    Color borderColor,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: (isDarkMode ? surfaceColor : Colors.white)
                .withOpacity(0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Health Records',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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

  Widget _buildRecordItem(
    BuildContext context, {
    required String docId,
    String? fileUrl,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Color? iconBgColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withOpacity(0.05),
      elevation: 1,
      child: InkWell(
        onTap: () async {
          if (fileUrl != null && fileUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RecordViewerScreen(fileUrl: fileUrl, title: title),
              ),
            );
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No file URL available.')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.red.shade900.withAlpha(26)
                  : Colors.red.shade50,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Record'),
                        content: const Text(
                          'Are you sure you want to delete this health record?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('health_records')
                          .doc(docId)
                          .delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Record deleted')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Record',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
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
        border: Border.all(
          color: isDarkMode ? primaryColor.withAlpha(51) : Colors.red.shade100,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload,
            color: isDarkMode ? primaryColor.withAlpha(77) : Colors.red[200],
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your records organized. All uploads are encrypted and secure.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
