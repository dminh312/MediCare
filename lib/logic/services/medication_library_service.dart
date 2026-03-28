import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationLibraryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medications_library';

  // Hàm tìm kiếm thuốc từ Firebase
  Future<List<String>> searchMedications(String query) async {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _firestore
        .collection(_collection)
        .where('searchName', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('searchName', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
  }
}
