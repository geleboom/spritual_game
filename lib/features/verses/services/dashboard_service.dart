import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';
import '../data/verses_data.dart';
import 'custom_verse_service.dart';

class DashboardService {
  final SharedPreferences _prefs;
  static const String _dashboardKey = 'dashboard_verses';
  static const int maxVerses = 5;

  DashboardService(this._prefs) {
    // Initialize with empty list if not exists
    if (!_prefs.containsKey(_dashboardKey)) {
      _prefs.setStringList(_dashboardKey, []);
    } else {
      // Ensure the stored value is a List<String>
      final dynamic currentValue = _prefs.get(_dashboardKey);
      if (currentValue is! List<String>) {
        _prefs.remove(_dashboardKey);
        _prefs.setStringList(_dashboardKey, []);
      }
    }
  }

  Future<List<Verse>> getDashboardVerses() async {
    final List<String>? verseIds = _prefs.getStringList(_dashboardKey);
    if (verseIds == null) return [];

    List<Verse> verses = [];

    // Get predefined verses
    for (var id in verseIds) {
      final verseId = int.parse(id);
      if (versesData.containsKey(verseId)) {
        verses.add(versesData[verseId]!);
      }
    }

    // Get custom verses
    final customVerses = await CustomVerseService.getCustomVerses();
    for (var id in verseIds) {
      final verseId = int.parse(id);
      final customVerse = customVerses.firstWhere(
        (verse) => verse.id == verseId,
        orElse: () => customVerses.first, // Return first verse as fallback
      );
      if (customVerse.id == verseId) {
        verses.add(customVerse);
      }
    }

    return verses;
  }

  Future<bool> addToDashboard(int verseId) async {
    try {
      List<String> verses = _prefs.getStringList(_dashboardKey) ?? [];
      if (!verses.contains(verseId.toString()) && verses.length < maxVerses) {
        verses.add(verseId.toString());
        return await _prefs.setStringList(_dashboardKey, verses);
      }
      return false;
    } catch (e) {
      await clearDashboard();
      return addToDashboard(verseId);
    }
  }

  Future<bool> removeFromDashboard(int verseId) async {
    try {
      List<String> verses = _prefs.getStringList(_dashboardKey) ?? [];
      verses.remove(verseId.toString());
      return await _prefs.setStringList(_dashboardKey, verses);
    } catch (e) {
      await clearDashboard();
      return true;
    }
  }

  Future<bool> isInDashboard(int verseId) async {
    try {
      List<String> verses = _prefs.getStringList(_dashboardKey) ?? [];
      return verses.contains(verseId.toString());
    } catch (e) {
      await clearDashboard();
      return false;
    }
  }

  Future<int> getDashboardVerseCount() async {
    try {
      List<String> verses = _prefs.getStringList(_dashboardKey) ?? [];
      return verses.length;
    } catch (e) {
      await clearDashboard();
      return 0;
    }
  }

  Future<bool> clearDashboard() async {
    try {
      await _prefs.remove(_dashboardKey);
      return await _prefs.setStringList(_dashboardKey, []);
    } catch (e) {
      return false;
    }
  }
}
