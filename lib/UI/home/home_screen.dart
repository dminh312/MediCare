import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/UI/home/notification/notification_center_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : const Color(0xFFffffff);
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

  Widget _buildFindPharmaciesCard(bool isDarkMode, Color surfaceColor, Color textColor) {
    const primaryColor = Color(0xFFff5252);
    final primaryLight = isDarkMode ? primaryColor.withValues(alpha: 0.2) : const Color(0xFFffebee);
    
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.red[900]!.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
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
                      Text("Find Pharmacies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 2),
                      Text("Locate the nearest medical stores", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.red[900]!.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            color: isDarkMode ? primaryColor.withValues(alpha: 0.1) : primaryLight,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 8,
                      backgroundColor: isDarkMode ? Colors.red[900]!.withValues(alpha: 0.3) : Colors.red[100],
                      color: primaryColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text("85%", style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  )),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900]),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're crushing it! Just 1,200 more steps to reach your daily target. Keep moving!",
                  style: TextStyle(height: 1.5, fontSize: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("View Details", style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(bool isDarkMode, Color surfaceColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Health Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFff5252), padding: EdgeInsets.zero),
              child: const Text("See All", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: "Steps",
                value: "8,432",
                icon: Icons.directions_walk,
                iconColor: Colors.orange[600]!,
                iconBgDark: Colors.orange[900]!.withValues(alpha: 0.3),
                iconBgLight: Colors.orange[100]!,
                trendValue: "5%",
                trendUp: true,
                isDarkMode: isDarkMode,
                surfaceColor: surfaceColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: "Water",
                value: "1.5L",
                icon: Icons.water_drop,
                iconColor: Colors.blue[600]!,
                iconBgDark: Colors.blue[900]!.withValues(alpha: 0.3),
                iconBgLight: Colors.blue[100]!,
                trendValue: "12%",
                trendUp: true,
                isDarkMode: isDarkMode,
                surfaceColor: surfaceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildHeartRateCard(isDarkMode, surfaceColor, textColor),
      ],
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
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.red[900]!.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
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
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900])),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(trendUp ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.green[600], size: 16),
                  const SizedBox(width: 2),
                  Text(trendValue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[600])),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(bool isDarkMode, Color surfaceColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.red[900]!.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
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
                  color: isDarkMode ? Colors.red[900]!.withValues(alpha: 0.3) : Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: Colors.red[600], size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Heart Rate", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("72", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(width: 4),
                      Text("bpm", style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[500])),
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
              color: isDarkMode ? Colors.red[900]!.withValues(alpha: 0.2) : Colors.red[50],
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
        color: isDarkMode ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final userName = _user?.displayName ?? 'User';
    final photoUrl = _user?.photoURL;

    return AppBar(
      toolbarHeight: 80,
      backgroundColor: isDarkMode ? const Color(0xFF1a1111).withValues(alpha: 0.95) : const Color(0xFFfffbfb).withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: isDarkMode ? Colors.red[900]!.withValues(alpha: 0.2) : Colors.red[100],
          height: 1.0,
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            backgroundImage: (photoUrl != null) ? NetworkImage(photoUrl) : null,
            child: (photoUrl == null)
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              Text(
                userName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
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
                final scheduledTime = (doc.data() as Map<String, dynamic>)['scheduledTime'] as Timestamp?;
                if (scheduledTime != null && scheduledTime.toDate().isBefore(now)) {
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
                    MaterialPageRoute(builder: (context) => const NotificationCenterScreen()),
                  );
                },
              ),
            );
          }
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
