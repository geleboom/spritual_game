import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _progressKey = 'verse_progress';
  static const String _practiceHistoryKey = 'practice_history';
  static const String _practiceDaysKey = 'practice_days';

  final SharedPreferences _prefs;

  ProgressService(this._prefs);

  // Get progress for a specific verse
  Future<double> getVerseProgress(int verseId) async {
    final progressMap = _getProgressMap();
    return progressMap[verseId]?.toDouble() ?? 0.0;
  }

  // Update progress after practice session
  Future<void> updateProgress(int verseId, List<bool> questionResults) async {
    final progressMap = _getProgressMap();

    // Calculate new progress based on recent performance
    double currentProgress = progressMap[verseId]?.toDouble() ?? 0.0;
    double sessionScore = questionResults.where((result) => result).length /
        questionResults.length;

    // Weight: 70% previous progress, 30% new score
    double newProgress = (currentProgress * 0.7) + (sessionScore * 0.3);

    // Update progress
    progressMap[verseId] = newProgress;
    await _saveProgressMap(progressMap);

    // Save practice history
    await _savePracticeHistory(verseId, questionResults);

    // Update practice days
    await _updatePracticeDays();
  }

  // Get practice days count
  Future<int> getPracticeDays() async {
    final practiceDays = _prefs.getStringList(_practiceDaysKey) ?? [];
    return practiceDays.length;
  }

  // Private methods
  Map<int, double> _getProgressMap() {
    final String? progressJson = _prefs.getString(_progressKey);
    if (progressJson == null) return {};

    Map<String, dynamic> jsonMap = jsonDecode(progressJson);
    return jsonMap.map((key, value) => MapEntry(int.parse(key), value));
  }

  Future<void> _saveProgressMap(Map<int, double> progressMap) async {
    final String progressJson = jsonEncode(progressMap);
    await _prefs.setString(_progressKey, progressJson);
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
