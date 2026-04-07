import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/services/firebase_services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => canResendEmail = true);
      });

      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 15));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is FirebaseAuthException && e.code == 'too-many-requests') {
          errorMessage = 'Bạn đã yêu cầu quá nhiều lần. Vui lòng đợi vài phút rồi thử lại nhé!';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Bạn đã yêu cầu quá nhiều lần. Vui lòng đợi vài phút rồi thử lại nhé!';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });
    if (isEmailVerified) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDarkMode
        ? [const Color(0xFF020617), const Color(0xFF0F172A)]
        : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)];

    return isEmailVerified
        ? const SizedBox() // Main logic stream will handle routing to HomeView
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Verify Email'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      [
                            const Icon(
                              Icons.mark_email_unread_outlined,
                              size: 100,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'A verification email has been sent to your email address.',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text(
                                'I\'ve Verified My Email',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: checkEmailVerified,
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              icon: const Icon(Icons.email),
                              label: const Text(
                                'Resend Email',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: canResendEmail
                                  ? sendVerificationEmail
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => FirebaseAuthService().signOut(),
                              child: const Text(
                                'Cancel / Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ]
                          .animate(interval: 50.ms)
                          .fade(duration: 400.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                ),
              ),
            ),
          );
  }
}
