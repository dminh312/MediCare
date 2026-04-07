import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class WeakNetworkException extends NetworkException {
  WeakNetworkException()
    : super('Connection is too weak. The request timed out.');
}

class OfflineException extends NetworkException {
  OfflineException() : super('No internet connection available.');
}

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Wraps a Firebase or network task with connectivity checks and timeout handling.
  Future<T> runNetworkTask<T>(
    Future<T> Function() task, {
    int timeoutSeconds = 10,
  }) async {
    // 1. Check if we have network first
    if (!await isConnected()) {
      throw OfflineException();
    }

    try {
      // 2. Execute task with timeout
      return await task().timeout(Duration(seconds: timeoutSeconds));
    } on TimeoutException {
      // 3. Catch weak network
      throw WeakNetworkException();
    } on FirebaseException catch (e) {
      if (e.code == 'network-request-failed' || e.code == 'unavailable') {
        throw OfflineException();
      }
      rethrow;
    }
  }
}
