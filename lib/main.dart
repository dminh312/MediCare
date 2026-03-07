import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicare/UI/home/home_view.dart';
import 'package:medicare/UI/login/login_screen.dart';
import 'package:medicare/logic/services/medication_library_service.dart';
import 'package:medicare/logic/viewmodels/forgot_password_viewmodel.dart';
import 'package:medicare/logic/viewmodels/login_viewmodel.dart';
import 'package:medicare/logic/viewmodels/medication_log_viewmodel.dart';
import 'package:medicare/logic/viewmodels/signup_viewmodel.dart';
import 'package:medicare/logic/services/notification_service.dart';
import 'package:medicare/UI/signup/verify_email_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  final notificationService = NotificationService();
  
  try {
    debugPrint("[SYSTEM] Initializing Firebase...");
    await Firebase.initializeApp();
    
    debugPrint("[SYSTEM] Initializing Notification Service...");
    await notificationService.init();
    debugPrint("[SYSTEM] Notification Service is ready!");
  } catch (e) {
    debugPrint("[SYSTEM ERROR] Initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(
          create: (_) => MedicationLogViewModel(notificationService: notificationService),
        ),
      ],
      child: const MyApp(),
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
    });
  }

  void _setupNotificationListener() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final medicationLogViewModel = Provider.of<MedicationLogViewModel>(context, listen: false);
    
    notificationService.onNotificationClick.stream.listen((payload) {
      debugPrint("[APP] User clicked notification with payload: $payload");
      if (payload != null && payload.isNotEmpty) {
        medicationLogViewModel.handleNotificationTap(payload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasData) {
          final isVerified = snapshot.data!.emailVerified;
          if (!isVerified) {
            return const VerifyEmailScreen();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _performPostLoginTasks(context);
          });
          return const HomeView();
        }
        return const LoginView();
      },
    );
  }

  void _performPostLoginTasks(BuildContext context) {
    final logViewModel = Provider.of<MedicationLogViewModel>(context, listen: false);
    
    // Reschedule notifications
    logViewModel.rescheduleAllNotifications();
    
    // Initialize medication library
    MedicationLibraryService().seedMedicationLibrary().catchError((e) {
      debugPrint("Error seeding medication library: $e");
    });
  }
}
