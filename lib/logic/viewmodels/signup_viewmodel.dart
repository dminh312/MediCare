import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/services/firebase_services.dart';
import 'package:medicare/logic/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<String?> signUp(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    try {
      await _authService.signUpWithEmailAndPassword(
        email,
        password,
        name,
        phoneNumber,
      );

      final prefs = await SharedPreferences.getInstance();
      await OnboardingService.reset(prefs);

      return null; // Return null on success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'weak-password':
          return 'The password provided is too weak, Please try again.';
        case 'invalid-email':
          return 'The email address is not valid, Please try again.';
        default:
          return 'An unknown error occurred. Please try again.';
      }
    }
  }
}
