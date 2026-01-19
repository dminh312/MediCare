import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare/logic/models/medication_model.dart';

class MedicationViewModel {
  final _db = FirebaseFirestore.instance.collection('medications');

  Future<void> addMedication(MedicationModel med) async {
    await _db.add(med.toFirestore());
  }

  Stream<List<MedicationModel>> getUserMedications(String userId) {
    return _db.where('userId', isEqualTo: userId).snapshots().map(
      (snap) => snap.docs.map((d) => MedicationModel.fromFirestore(d)).toList(),
    );
  }
}
