import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/services/app_lifecycle_manager.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicare/UI/home/home_view.dart';
import 'package:medicare/UI/login/login_screen.dart';
import 'package:medicare/logic/viewmodels/forgot_password_viewmodel.dart';
import 'package:medicare/logic/viewmodels/login_viewmodel.dart';
import 'package:medicare/logic/viewmodels/medication_log_viewmodel.dart';
import 'package:medicare/logic/viewmodels/signup_viewmodel.dart';
import 'package:medicare/logic/services/notification_service.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';
import 'package:medicare/UI/signup/verify_email_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/UI/onboarding/welcome_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  final notificationService = NotificationService();

  try {
    await Firebase.initializeApp();
    await notificationService.init();
  } catch (e) {
    // ignore
  }

  runApp(
    AppLifecycleManager(
      child: MultiProvider(
        providers: [
          Provider<NotificationService>.value(value: notificationService),
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => SignUpViewModel()),
          ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
          ChangeNotifierProvider(
            create: (_) =>
                MedicationLogViewModel(notificationService: notificationService),
          ),
          ChangeNotifierProvider(create: (_) => HealthDataViewModel()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListener();
      _checkInternetConnection();
    });
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('Offline');
      }
    } catch (_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _setupNotificationListener() {
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
    final medicationLogViewModel = Provider.of<MedicationLogViewModel>(
      context,
      listen: false,
    );

    notificationService.onNotificationClick.stream.listen((payload) {
      if (payload != null && payload.isNotEmpty) {
        medicationLogViewModel.handleNotificationTap(payload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'MediCare+',
      debugShowCheckedModeBanner: false,
      builder: BotToastInit(), // Initialize BotToast
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ], // Register BotToast observer
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final isVerified = snapshot.data!.emailVerified;
          if (!isVerified) {
            return const VerifyEmailScreen();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _performPostLoginTasks(context);
          });

          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, prefSnapshot) {
              if (prefSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final prefs = prefSnapshot.data;
              final hasCompletedOnboarding =
                  prefs?.getBool('has_completed_onboarding') ?? false;

              if (!hasCompletedOnboarding) {
                return const WelcomeScreen();
              }

              return const HomeView();
            },
          );
        }
        return const LoginView();
      },
    );
  }

  void _performPostLoginTasks(BuildContext context) {
    final logViewModel = Provider.of<MedicationLogViewModel>(
      context,
      listen: false,
    );

    // Reschedule notifications
    logViewModel.rescheduleAllNotifications();
  }
}
