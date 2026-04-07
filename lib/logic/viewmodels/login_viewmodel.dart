import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/services/firebase_services.dart';
import 'package:medicare/logic/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<String?> signIn(String email, String password) async {
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        await _authService.signOut();
        return 'Please verify your email before logging in.';
      }

      return null; // Return null on success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password, Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An unknown error occurred. Please try again.';
      }
    } catch (e) {
      GlobalErrorHandler.handleError(e);
      return 'Network or system error occurred.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null &&
          user.metadata.creationTime != null &&
          user.metadata.lastSignInTime != null) {
        // If the account was just created, reset onboarding
        if (user.metadata.lastSignInTime!
                .difference(user.metadata.creationTime!)
                .inSeconds < 60) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_completed_onboarding', false);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unknown error occurred. Please try again.';
    }
  }
}
