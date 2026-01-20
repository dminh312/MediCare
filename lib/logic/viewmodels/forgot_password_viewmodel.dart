import 'package:flutter/material.dart';
import 'package:medicare/logic/sevices/firebase_services.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
