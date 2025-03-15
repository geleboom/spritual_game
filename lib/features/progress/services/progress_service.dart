import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  final SharedPreferences _prefs;
  static const String _progressPrefix = 'verse_progress_';
  static const String _practiceDaysKey = 'practice_days';
  static const String _practiceHistoryKey = 'practice_history';

  ProgressService(this._prefs);

  // Get progress for a specific verse and mode
  Future<double> getVerseProgress(int verseId, {String? mode}) async {
    try {
      final key = mode != null
          ? '$_progressPrefix${mode}_$verseId'
          : '$_progressPrefix$verseId';
      final progress = _prefs.getDouble(key);
      return progress ?? 0.0;
    } catch (e) {
      print('Error in getVerseProgress: $e');
      return 0.0;
    }
  }

  // Get practice days count
  Future<int> getPracticeDays() async {
    return _prefs.getInt(_practiceDaysKey) ?? 0;
  }

  // Update progress after practice session
  Future<void> updateProgress(int verseId, List<bool> questionResults,
      {String? mode}) async {
    try {
      final key = mode != null
          ? '$_progressPrefix${mode}_$verseId'
          : '$_progressPrefix$verseId';

      // Calculate new progress based on recent performance
      double currentProgress = await getVerseProgress(verseId, mode: mode);
      double sessionScore = questionResults.where((result) => result).length /
          questionResults.length *
          100; // Convert to percentage

      // Weight: 70% previous progress, 30% new score
      double newProgress = (currentProgress * 0.7) + (sessionScore * 0.3);

      // Store progress directly as double
      await _prefs.setDouble(key, newProgress);

      print(
          'Saved progress for verse $verseId (${mode ?? 'default'}): $newProgress%');

      // Save practice history
      await _savePracticeHistory(verseId, questionResults);

      // Update practice days
      await _updatePracticeDays();
    } catch (e) {
      print('Error in updateProgress: $e');
      rethrow;
    }
  }

  // Private methods
  Map<int, double> _getProgressMap(String? mode) {
    final key = mode != null ? '$_progressPrefix$mode' : _progressPrefix;
    final String? progressJson = _prefs.getString(key);
    if (progressJson == null) return {};

    Map<String, dynamic> jsonMap = jsonDecode(progressJson);
    return Map<int, double>.from(jsonMap
        .map((key, value) => MapEntry(int.parse(key), value.toDouble())));
  }

  Future<void> _saveProgressMap(
      Map<int, double> progressMap, String? mode) async {
    final key = mode != null ? '$_progressPrefix$mode' : _progressPrefix;
    final Map<String, dynamic> jsonMap =
        progressMap.map((key, value) => MapEntry(key.toString(), value));
    final String progressJson = jsonEncode(jsonMap);
    await _prefs.setString(key, progressJson);
  }

  Future<void> _updatePracticeDays() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final practiceDays = _prefs.getStringList(_practiceDaysKey) ?? [];

    if (!practiceDays.contains(today)) {
      practiceDays.add(today);
      await _prefs.setStringList(_practiceDaysKey, practiceDays);
    }
  }

  Future<void> _savePracticeHistory(int verseId, List<bool> results) async {
    final session = PracticeSession(
      timestamp: DateTime.now(),
      score: results.where((result) => result).length / results.length,
      totalQuestions: results.length,
      correctAnswers: results.where((result) => result).length,
    );

    List<PracticeSession> history = await getPracticeHistory(verseId);
    history.add(session);

    if (history.length > 10) {
      history = history.sublist(history.length - 10);
    }

    final String historyJson =
        jsonEncode(history.map((s) => s.toJson()).toList());
    await _prefs.setString('${_practiceHistoryKey}_$verseId', historyJson);
  }

  // Get practice history for statistics
  Future<List<PracticeSession>> getPracticeHistory(int verseId) async {
    final String? historyJson =
        _prefs.getString('${_practiceHistoryKey}_$verseId');
    if (historyJson == null) return [];

    List<dynamic> historyList = jsonDecode(historyJson);
    return historyList.map((item) => PracticeSession.fromJson(item)).toList();
  }
}

class PracticeSession {
  final DateTime timestamp;
  final double score;
  final int totalQuestions;
  final int correctAnswers;

  PracticeSession({
    required this.timestamp,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'score': score,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
      };

  factory PracticeSession.fromJson(Map<String, dynamic> json) =>
      PracticeSession(
        timestamp: DateTime.parse(json['timestamp']),
        score: json['score'],
        totalQuestions: json['totalQuestions'],
        correctAnswers: json['correctAnswers'],
      );
}
