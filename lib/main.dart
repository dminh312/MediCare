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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  
  try {
    debugPrint("[SYSTEM] Đang khởi tạo Firebase...");
    await Firebase.initializeApp();
    
    debugPrint("[SYSTEM] Đang khởi tạo Notification Service...");
    await notificationService.init();
    debugPrint("[SYSTEM] Notification Service đã sẵn sàng!");
  } catch (e) {
    debugPrint("[SYSTEM ERROR] Lỗi khởi tạo: $e");
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
      debugPrint("[APP] Người dùng nhấn vào thông báo với payload: $payload");
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
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasData) {
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
    
    // Đặt lại lịch thông báo
    logViewModel.rescheduleAllNotifications();
    
    // Khởi tạo thư viện thuốc
    MedicationLibraryService().seedMedicationLibrary().catchError((e) {
      debugPrint("Error seeding medication library: $e");
    });
  }
}
