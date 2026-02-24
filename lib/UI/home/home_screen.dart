import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/logic/services/notification_service.dart';

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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await NotificationService().showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi thông báo test! Hãy kiểm tra thanh trạng thái.')),
                );
              },
              icon: const Icon(Icons.notification_add),
              label: const Text('Bấm để Test Thông Báo Ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff5252),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Add some space
            ElevatedButton.icon(
              onPressed: () async {
                await NotificationService().scheduleTestNotification10s();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lên lịch thông báo test sau 10 giây!')),
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Test Thông Báo sau 10 giây'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
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
      backgroundColor: isDarkMode ? const Color(0xFF1a1111).withOpacity(0.95) : const Color(0xFFfffbfb).withOpacity(0.95),
      elevation: 0.5,
      scrolledUnderElevation: 1,
      shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.1),
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
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, size: 28),
          onPressed: () {
             NotificationService().showTestNotification();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
