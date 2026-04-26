import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _auth = FirebaseAuth.instance;
  late final Stream<List<Map<String, dynamic>>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _notificationStream = _getNotificationStream();
  }

  Stream<List<Map<String, dynamic>>> _getNotificationStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('medication_logs')
        .where('userId', isEqualTo: user.uid)
        .where('scheduledTime', isLessThan: Timestamp.fromDate(DateTime.now()))
        .limit(100)
        .snapshots()
        .asyncMap((logSnapshot) async {
          if (logSnapshot.docs.isEmpty) return [];

          final medicationIds = logSnapshot.docs
              .map((doc) => doc.data()['medicationId'] as String)
              .toSet()
              .toList();
          if (medicationIds.isEmpty) return [];

          final Map<String, MedicationModel> medicationsMap = {};

          for (var i = 0; i < medicationIds.length; i += 10) {
            final chunk = medicationIds.sublist(
              i,
              i + 10 > medicationIds.length ? medicationIds.length : i + 10,
            );

            final medicationSnapshot = await FirebaseFirestore.instance
                .collection('medications')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

            for (var doc in medicationSnapshot.docs) {
              medicationsMap[doc.id] = MedicationModel.fromFirestore(doc);
            }
          }

          final viewDataList = <Map<String, dynamic>>[];
          for (final logDoc in logSnapshot.docs) {
            final log = MedicationLog.fromFirestore(logDoc);
            final medication = medicationsMap[log.medicationId];

            if (medication != null) {
              viewDataList.add({'log': log, 'medication': medication});
            }
          }

          // Manually sort in Dart to avoid requiring a Firestore Composite Index
          viewDataList.sort((a, b) {
            final logA = a['log'] as MedicationLog;
            final logB = b['log'] as MedicationLog;
            return logB.scheduledTime.compareTo(logA.scheduledTime);
          });

          return viewDataList.take(50).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF191C1E)
        : const Color(0xFFF7F9FB);
    final surfaceColor = isDarkMode ? const Color(0xFF2D3133) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF191C1E);
    final textVariantColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF5B403E);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ).animate().fadeIn(duration: 300.ms),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB51925)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.inter(color: const Color(0xFFBA1A1A)),
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_off_rounded,
                          size: 64,
                          color: textColor.withValues(alpha: 0.3),
                        ),
                      )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .fadeIn(),
                  const SizedBox(height: 24),
                  Text(
                    'All caught up',
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'No new notifications to display',
                    style: GoogleFonts.inter(
                      color: textVariantColor,
                      fontSize: 15,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                ],
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  left: 16,
                  right: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = items[index];
                    final log = data['log'] as MedicationLog;
                    final med = data['medication'] as MedicationModel;

                    final isToday =
                        log.scheduledTime.toDate().day == DateTime.now().day &&
                        log.scheduledTime.toDate().month ==
                            DateTime.now().month &&
                        log.scheduledTime.toDate().year == DateTime.now().year;

                    final timeString = isToday
                        ? 'Today, ${DateFormat('h:mm a').format(log.scheduledTime.toDate())}'
                        : DateFormat(
                            'MMM d, h:mm a',
                          ).format(log.scheduledTime.toDate());

                    IconData medIcon;
                    Color statusColor;
                    Color statusBgColor;
                    String statusText;

                    switch (med.form) {
                      case MedicationForm.pill:
                      case MedicationForm.tablet:
                      case MedicationForm.capsule:
                        medIcon = Icons.medication_rounded;
                        break;
                      case MedicationForm.injection:
                        medIcon = Icons.vaccines_rounded;
                        break;
                      case MedicationForm.syrup:
                        medIcon = Icons.medication_liquid_rounded;
                        break;
                    }

                    switch (log.status) {
                      case MedicationStatus.taken:
                        statusText = 'TAKEN';
                        statusColor = const Color(0xFF006856); // Tertiary Green
                        statusBgColor = const Color(0xFFF4FFF9);
                        break;
                      case MedicationStatus.missed:
                        statusText = 'MISSED';
                        statusColor = const Color(0xFFB51925); // Primary Red
                        statusBgColor = const Color(0xFFFFF7F7);
                        break;
                      case MedicationStatus.upcoming:
                        statusText = 'UPCOMING';
                        statusColor = const Color(0xFF005FB8); // Blue
                        statusBgColor = const Color(0xFFF4FAFF);
                        break;
                    }

                    if (isDarkMode) {
                      statusBgColor = statusColor.withValues(alpha: 0.15);
                    }

                    return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: surfaceColor.withValues(
                                    alpha: isDarkMode ? 0.6 : 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.withValues(alpha: 0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        medIcon,
                                        color: statusColor,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Take ${med.name}',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 17,
                                                    color: textColor,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                timeString,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: textVariantColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Dosage: ${med.dosage} • ${med.timing}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: textVariantColor,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: GoogleFonts.inter(
                                                color: statusColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (index * 50).ms)
                        .slideY(
                          begin: 0.1,
                          duration: 500.ms,
                          curve: Curves.easeOutQuad,
                          delay: (index * 50).ms,
                        );
                  }, childCount: items.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
