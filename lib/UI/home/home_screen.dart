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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page (brb)'),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final userName = _user?.displayName ?? 'User';
    final photoUrl = _user?.photoURL;

    return AppBar(
      toolbarHeight: 80,
      backgroundColor: isDarkMode ? const Color(0xFF1a1111).withValues(alpha: 0.95) : const Color(0xFFfffbfb).withValues(alpha: 0.95),
      elevation: 0.5,
      scrolledUnderElevation: 1,
      shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
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
