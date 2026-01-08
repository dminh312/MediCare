import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare/UI/login/login_view.dart';
import 'package:medicare/logic/viewmodels/login_viewmodel.dart';
import 'package:medicare/logic/viewmodels/signup_viewmodel.dart';
import 'package:medicare/logic/viewmodels/forgot_password_viewmodel.dart'; // Import ForgotPasswordViewModel

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()), // Add ForgotPasswordViewModel
      ],
      child: MaterialApp(
        title: 'MediCare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const LoginView(),
      ),
    );
  }
}
