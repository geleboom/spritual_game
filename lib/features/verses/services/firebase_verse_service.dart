// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/verse.dart';

// class FirebaseVerseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<Verse>> getVerses() async {
//     try {
//       final QuerySnapshot snapshot = await _firestore.collection('verses').get();
      
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Verse(
//           id: int.parse(doc.id),
//           reference: data['reference'] ?? '',
//           referenceTranslation: data['referenceTranslation'] ?? '',
//           verseText: data['verseText'] ?? '',
//           translation: data['translation'] ?? '',
//         );
//       }).toList();
//     } catch (e) {
//       debugPrint('Error fetching verses: $e');
//       return [];
//     }
//   }

//   Future<List<Verse>> getVersesByCategory(String categoryId) async {
//     try {
//       final QuerySnapshot snapshot = await _firestore
//           .collection('verses')
//           .where('categoryId', isEqualTo: categoryId)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Verse(
//           id: int.parse(doc.id),
//           reference: data['reference'] ?? '',
//           referenceTranslation: data['referenceTranslation'] ?? '',
//           verseText: data['verseText'] ?? '',
//           translation: data['translation'] ?? '',
//         );
//       }).toList();
//     } catch (e) {
//       debugPrint('Error fetching verses by category: $e');
//       return [];
//     }
//   }

//   Stream<List<Verse>> streamVerses() {
//     return _firestore.collection('verses').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Verse(
//           id: int.parse(doc.id),
//           reference: data['reference'] ?? '',
//           referenceTranslation: data['referenceTranslation'] ?? '',
//           verseText: data['verseText'] ?? '',
//           translation: data['translation'] ?? '',
//         );
//       }).toList();
//     });
//   }
// }