import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/UI/auth/app_lock_screen.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  DateTime? _pausedTime;
  bool _isLockScreenShowing = false;
  bool _shouldLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // We check lock initially after frame is built so Navigator is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final diff = DateTime.now().difference(_pausedTime!);
        if (diff.inMinutes >= 15) {
          _checkLock();
        }
      }
    }
  }

  Future<void> _checkLock() async {
    final prefs = await SharedPreferences.getInstance();
    final isLockEnabled = prefs.getBool('is_biometric_lock_enabled') ?? false;

    if (isLockEnabled && !_isLockScreenShowing) {
      setState(() {
        _shouldLock = true;
        _isLockScreenShowing = true;
      });
    }
  }

  void _onUnlock() {
    setState(() {
      _shouldLock = false;
      _isLockScreenShowing = false;
      _pausedTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldLock) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: AppLockScreen(
          onUnlock: _onUnlock,
        ),
      );
    }
    return widget.child;
  }
}
