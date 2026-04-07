import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/network_service.dart';

class GlobalErrorHandler {
  static void handleError(Object error, [StackTrace? stackTrace]) {
    String errorMessage = "An unexpected error occurred.";

    if (error is OfflineException) {
      errorMessage = "No internet connection. Please check your network.";
    } else if (error is WeakNetworkException) {
      errorMessage = "Connection is weak. Please try again.";
    } else if (error is FirebaseException) {
      errorMessage = error.message ?? "A database error occurred.";
    } else {
      errorMessage = error.toString();
    }

    BotToast.showText(
      text: errorMessage,
      contentColor: Colors.redAccent,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      duration: const Duration(seconds: 4),
      align: const Alignment(0, -0.8), // Show near the top
    );

    // Optional: Log to some analytics/monitoring service
    debugPrint("GlobalErrorHandler caught: $error");
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
