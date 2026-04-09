import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/UI/home/notification/notification_center_screen.dart';
import 'package:medicare/UI/home/maps_screen.dart';
import 'package:medicare/UI/track/heart_rate/heart_rate_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';
import 'package:medicare/UI/track/step_screen/step_activity_screen.dart';
import 'package:medicare/UI/components/permission_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF1a1111)
        : const Color(0xFFfffbfb);
    final surfaceColor = isDarkMode
        ? const Color(0xFF2d1f1f)
        : const Color(0xFFffffff);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111714);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyGoalProgress(isDarkMode, surfaceColor),
            const SizedBox(height: 24),
            _buildHealthMetrics(isDarkMode, surfaceColor, textColor),
            const SizedBox(height: 24),
            _buildFindPharmaciesCard(isDarkMode, surfaceColor, textColor),
            const SizedBox(height: 16),
            _buildPlaceholder("History Log...", isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFindPharmaciesCard(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
  ) {
    const primaryColor = Color(0xFFff5252);
    final primaryLight = isDarkMode
        ? primaryColor.withValues(alpha: 0.2)
        : const Color(0xFFffebee);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.red[900]!.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.map, color: primaryColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find Pharmacies",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Locate the nearest medical stores",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                  ),
                  child: const Icon(Icons.arrow_forward, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalProgress(bool isDarkMode, Color surfaceColor) {
    const primaryColor = Color(0xFFff5252);
    const primaryLight = Color(0xFFffebee);

    return Consumer<HealthDataViewModel>(
      builder: (context, viewModel, child) {
        int todaySteps = viewModel.todaySteps;
        int stepGoal = viewModel.stepGoal;
        double progress = stepGoal > 0 ? (todaySteps / stepGoal).clamp(0.0, 1.0) : 0.0;
        int remaining = stepGoal - todaySteps;
        String subtitleText = remaining > 0 
          ? "You're crushing it! Just $remaining more steps to reach your daily target. Keep moving!"
          : "You've reached your daily step goal! Amazing job!";

        return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.red[900]!.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            color: isDarkMode
                ? primaryColor.withValues(alpha: 0.1)
                : primaryLight,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: isDarkMode
                          ? Colors.red[900]!.withValues(alpha: 0.3)
                          : Colors.red[100],
                      color: primaryColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Goal Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StepActivityScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "View Details",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildHealthMetrics(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
  ) {
    return Consumer<HealthDataViewModel>(
      builder: (context, viewModel, child) {
        final isConnected = viewModel.isConnected;

        // Define the content
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Health Metrics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFff5252),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "See All",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: isConnected
                        ? _buildMetricCard(
                            title: "Steps",
                            value: "${viewModel.todaySteps}",
                            icon: Icons.directions_walk,
                          iconColor: Colors.orange[600]!,
                          iconBgDark: Colors.orange[900]!.withValues(
                            alpha: 0.3,
                          ),
                          iconBgLight: Colors.orange[100]!,
                          trendValue: "Goal 10k",
                          trendUp: true,
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                        )
                      : _buildLockedCard(
                          title: "Steps",
                          icon: Icons.directions_walk,
                          iconColor: Colors.orange[600]!,
                          iconBgDark: Colors.orange[900]!.withValues(
                            alpha: 0.3,
                          ),
                          iconBgLight: Colors.orange[100]!,
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (isConnected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HeartRateScreen(),
                    ),
                  );
                } else {
                  _showUnauthorizedDialog(context);
                }
              },
              child: isConnected
                  ? _buildHeartRateCard(
                      isDarkMode,
                      surfaceColor,
                      textColor,
                      viewModel.latestHeartRate,
                    )
                  : _buildLockedHeartRateCard(
                      isDarkMode,
                      surfaceColor,
                      textColor,
                    ),
            ),
          ],
        );

        return content;
      },
    );
  }

  void _showUnauthorizedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PermissionDialog(),
    );
  }

  Widget _buildLockedCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgDark,
    required Color iconBgLight,
    required bool isDarkMode,
    required Color surfaceColor,
  }) {
    return GestureDetector(
      onTap: () => _showUnauthorizedDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? Colors.white10
                : Colors.red[900]!.withValues(alpha: 0.05),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkMode ? iconBgDark : iconBgLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "...", // Placeholder line
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Locked",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedHeartRateCard(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.red[900]!.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.red[900]!.withValues(alpha: 0.3)
                                : Colors.red[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Heart Rate",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                            Text(
                              "...",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 80, height: 40),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Locked",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgDark,
    required Color iconBgLight,
    required String trendValue,
    required bool trendUp,
    required bool isDarkMode,
    required Color surfaceColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.red[900]!.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? iconBgDark : iconBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                  children: [
                    Icon(
                      trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.green[600],
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trendValue,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                ), // Close Padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    int heartRate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.red[900]!.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.red[900]!.withValues(alpha: 0.3)
                      : Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: Colors.red[600], size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Heart Rate",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$heartRate",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                        "bpm",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                      ),
                      ), // Close Padding
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 40,
            width: 80,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.red[900]!.withValues(alpha: 0.2)
                  : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4, Colors.red[200]!),
                _buildBar(0.6, Colors.red[300]!),
                _buildBar(0.5, Colors.red[400]!),
                _buildBar(0.8, Colors.red[500]!),
                _buildBar(0.65, Colors.red[400]!),
                _buildBar(0.55, Colors.red[300]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String text, bool isDarkMode) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]!.withValues(alpha: 0.5)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final userName = _user?.displayName ?? 'User';
    final photoUrl = _user?.photoURL;

    return AppBar(
      toolbarHeight: 80,
      backgroundColor: isDarkMode
          ? const Color(0xFF1a1111).withValues(alpha: 0.95)
          : const Color(0xFFfffbfb).withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: isDarkMode
          ? Colors.transparent
          : Colors.grey.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: isDarkMode
              ? Colors.red[900]!.withValues(alpha: 0.2)
              : Colors.red[100],
          height: 1.0,
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            backgroundImage: (photoUrl != null) ? NetworkImage(photoUrl) : null,
            onBackgroundImageError: (photoUrl != null)
                ? (exception, stackTrace) {
                    debugPrint('Image load failed: $exception');
                  }
                : null,
            child: (photoUrl == null)
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        StreamBuilder<QuerySnapshot>(
          stream: _user != null
              ? FirebaseFirestore.instance
                    .collection('medication_logs')
                    .where('userId', isEqualTo: _user!.uid)
                    .where('status', isEqualTo: 'upcoming')
                    .snapshots()
              : const Stream.empty(),
          builder: (context, snapshot) {
            int unreadCount = 0;
            if (snapshot.hasData) {
              final now = DateTime.now();
              for (var doc in snapshot.data!.docs) {
                final scheduledTime =
                    (doc.data() as Map<String, dynamic>)['scheduledTime']
                        as Timestamp?;
                if (scheduledTime != null &&
                    scheduledTime.toDate().isBefore(now)) {
                  unreadCount++;
                }
              }
            }

            return Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString()),
              backgroundColor: const Color(0xFFff5252),
              offset: const Offset(-6, 6),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenterScreen(),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
