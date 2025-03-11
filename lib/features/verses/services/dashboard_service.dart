import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String _dashboardKey = 'dashboard_verses';
  static const int maxVerses = 5;
  final SharedPreferences _prefs;

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

  Future<List<int>> getDashboardVerses() async {
    try {
      final List<String> verses = _prefs.getStringList(_dashboardKey) ?? [];
      return verses.map((e) => int.parse(e)).toList();
    } catch (e) {
      await clearDashboard();
      return [];
    }
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
