import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/medication_log_model.dart';

class MedicationLogViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance.collection('med_logs');
  StreamSubscription? _logSubscription;

  List<MedicationLogModel> _logs = [];
  List<MedicationLogModel> get logs => _logs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setLogs(List<MedicationLogModel> logs) {
    _logs = logs;
  }

  Future<void> updateStatus(MedicationLogModel log) async {
    try {
      await _db.doc(log.id).set(log.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      _setError("Error updating medication status.");
    }
  }

  void fetchLogsByDate(String userId, DateTime date) {
    _setLoading(true);
    _setError(null);
    _logSubscription?.cancel(); // Hủy subscription trước đó

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final stream = _db
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicationLogModel.fromFirestore(doc))
            .toList());

    _logSubscription = stream.listen((logs) {
      _setLogs(logs);
      _setLoading(false);
    }, onError: (error) {
      _setError("Error loading medication history.");
      _setLoading(false);
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }
}
