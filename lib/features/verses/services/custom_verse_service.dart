import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';

class CustomVerseService {
  static const String _storageKey = 'custom_verses';
  static const String _lastIdKey = 'last_verse_id';

  // Get all custom verses
  static Future<List<Verse>> getCustomVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? versesJson = prefs.getString(_storageKey);

    if (versesJson == null) return [];

    final List<dynamic> versesList = json.decode(versesJson);
    return versesList.map((json) => Verse.fromJson(json)).toList();
  }

  // Add a new custom verse
  static Future<void> addCustomVerse(Verse verse) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing verses
    final List<Verse> existingVerses = await getCustomVerses();

    // Add new verse
    existingVerses.add(verse);

    // Convert to JSON and save
    final String versesJson = json.encode(
      existingVerses.map((v) => v.toJson()).toList(),
    );

    await prefs.setString(_storageKey, versesJson);
  }

  // Get the next available verse ID
  static Future<int> getNextVerseId() async {
    final prefs = await SharedPreferences.getInstance();
    final int lastId =
        prefs.getInt(_lastIdKey) ?? 1000; // Start from 1000 to avoid conflicts

    await prefs.setInt(_lastIdKey, lastId + 1);
    return lastId + 1;
  }

  // Delete a custom verse
  static Future<void> deleteCustomVerse(int verseId) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing verses
    final List<Verse> existingVerses = await getCustomVerses();

    // Remove the verse with matching ID
    existingVerses.removeWhere((verse) => verse.id == verseId);

    // Convert to JSON and save
    final String versesJson = json.encode(
      existingVerses.map((v) => v.toJson()).toList(),
    );

    await prefs.setString(_storageKey, versesJson);
  }
}
