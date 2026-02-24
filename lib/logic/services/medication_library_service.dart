import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationLibraryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medications_library';

  // Danh sách 100 loại thuốc phổ biến tại Việt Nam
  static const List<String> _vietnamMedications = [
    'Paracetamol', 'Panadol Extra', 'Hapacol 650', 'Efferalgan', 'Ibuprofen', 
    'Gofen 400', 'Alaxan', 'Aspirin', 'Diclofenac', 'Naproxen', 
    'Meloxicam', 'Celecoxib', 'Amoxicillin', 'Augmentin', 'Cephalexin', 
    'Cefuroxime', 'Zinnat 500mg', 'Azithromycin', 'Zithromax', 'Clarithromycin', 
    'Klacid', 'Levofloxacin', 'Ciprofloxacin', 'Metronidazole', 'Flagyl', 
    'Omeprazole', 'Losec', 'Esomeprazole', 'Nexium 40mg', 'Pantoprazole', 
    'Rabeprazole', 'Pariet', 'Famotidine', 'Ranitidine', 'Phosphalugel', 
    'Gaviscon', 'Smecta', 'Actapulgite', 'Berberin', 'Loperamide', 
    'Imodium', 'Oresol', 'Domperidone', 'Motilium M', 'Metoclopramide', 
    'Primperan', 'Salbutamol', 'Ventolin', 'Terbutaline', 'Bricanyl', 
    'Bromhexine', 'Bisolvon', 'Ambroxol', 'Acemuc', 'Acetylcysteine', 
    'Cetirizine', 'Zyrtec', 'Loratadine', 'Clarityne', 'Fexofenadine', 
    'Telfast 180mg', 'Chlorpheniramine', 'Decolgen Forte', 'Tiffy', 'Amlodipine', 
    'Nifedipine', 'Adalat', 'Enalapril', 'Lisinopril', 'Losartan', 
    'Valsartan', 'Telmisartan', 'Micardis', 'Atenolol', 'Metoprolol', 
    'Bisoprolol', 'Concor', 'Atorvastatin', 'Lipitor', 'Rosuvastatin', 
    'Crestor', 'Simvastatin', 'Fenofibrate', 'Metformin', 'Glucophage', 
    'Gliclazide', 'Diamicron MR', 'Insulin', 'Diazepam', 'Mimosa', 
    'Rotunda', 'Vitamin C', 'Enervon', 'Ceelin', 'Vitamin D3', 
    'Calcium Corbiere', 'Magne B6', 'Neurobion', 'Boganic', 'Kim Tiền Thảo', 
    'Diệp Hạ Châu', 'Hoạt huyết dưỡng não', 'Ginkgo Biloba', 'Tanakan'
  ];

  // Hàm đẩy dữ liệu lên Firebase nếu chưa tồn tại
  Future<void> seedMedicationLibrary() async {
    final snapshot = await _firestore.collection(_collection).limit(1).get();
    if (snapshot.docs.isEmpty) {
      print('Seeding medication library to Firestore...');
      final batch = _firestore.batch();
      for (var med in _vietnamMedications) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, {
          'name': med,
          'searchName': med.toLowerCase(),
        });
      }
      await batch.commit();
      print('Seeding complete!');
    }
  }

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
