import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/logic/services/firebase_services.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<String?> signIn(String email, String password) async {
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      
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
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unknown error occurred. Please try again.';
    }
  }
}
