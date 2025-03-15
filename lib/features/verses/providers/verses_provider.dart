import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../data/verses_data.dart';

class VersesProvider extends ChangeNotifier {
  final Map<int, Verse> _verses = versesData;

  // Getters
  Map<int, Verse> get verses => _verses;
  int get verseCount => _verses.length;

  // Basic verse operations
  Verse? getVerseById(int id) => _verses[id];

  List<Verse> getVersesByRange(int start, int end) {
    return _verses.entries
        .where((entry) => entry.key >= start && entry.key <= end)
        .map((entry) => entry.value)
        .toList();
  }

  // Language-specific getters
  String getVerseText(Verse verse, String language) {
    return language == 'am' ? verse.verseText : verse.translation;
  }

  String getVerseReference(Verse verse, String language) {
    return language == 'am' ? verse.reference : verse.referenceTranslation;
  }

  // Search functionality
  List<Verse> searchVerses(String query, String language) {
    query = query.toLowerCase();
    return _verses.values.where((verse) {
      final text = getVerseText(verse, language).toLowerCase();
      final reference = getVerseReference(verse, language).toLowerCase();
      return text.contains(query) || reference.contains(query);
    }).toList();
  }

  // Navigation helpers
  Verse? getNextVerse(int currentId) {
    final keys = _verses.keys.toList()..sort();
    final currentIndex = keys.indexOf(currentId);
    if (currentIndex < keys.length - 1) {
      return _verses[keys[currentIndex + 1]];
    }
    return null;
  }

  Verse? getPreviousVerse(int currentId) {
    final keys = _verses.keys.toList()..sort();
    final currentIndex = keys.indexOf(currentId);
    if (currentIndex > 0) {
      return _verses[keys[currentIndex - 1]];
    }
    return null;
  }
}
