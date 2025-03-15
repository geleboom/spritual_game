// class VerseAdminScreen extends StatefulWidget {
//   @override
//   _VerseAdminScreenState createState() => _VerseAdminScreenState();
// }

// class _VerseAdminScreenState extends State<VerseAdminScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _reference = TextEditingController();
//   final _referenceTranslation = TextEditingController();
//   final _verseText = TextEditingController();
//   final _translation = TextEditingController();
//   String _selectedCategory = 'faith';

//   Future<void> _addVerse() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       await FirebaseFirestore.instance.collection('verses').add({
//         'reference': _reference.text,
//         'referenceTranslation': _referenceTranslation.text,
//         'verseText': _verseText.text,
//         'translation': _translation.text,
//         'categoryId': _selectedCategory,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Verse added successfully')),
//       );
      
//       _clearForm();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error adding verse: $e')),
//       );
//     }
//   }

//   void _clearForm() {
//     _reference.clear();
//     _referenceTranslation.clear();
//     _verseText.clear();
//     _translation.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Verse')),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             TextFormField(
//               controller: _reference,
//               decoration: const InputDecoration(labelText: 'Reference (Amharic)'),
//               validator: (v) => v!.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _referenceTranslation,
//               decoration: const InputDecoration(labelText: 'Reference (English)'),
//               validator: (v) => v!.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _verseText,
//               decoration: const InputDecoration(labelText: 'Verse Text (Amharic)'),
//               validator: (v) => v!.isEmpty ? 'Required' : null,
//               maxLines: 3,
//             ),
//             TextFormField(
//               controller: _translation,
//               decoration: const InputDecoration(labelText: 'Translation (English)'),
//               validator: (v) => v!.isEmpty ? 'Required' : null,
//               maxLines: 3,
//             ),
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               items: VerseCategory.categories.map((cat) {
//                 return DropdownMenuItem(
//                   value: cat.id,
//                   child: Text(cat.name),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => _selectedCategory = value!);
//               },
//               decoration: const InputDecoration(labelText: 'Category'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _addVerse,
//               child: const Text('Add Verse'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }