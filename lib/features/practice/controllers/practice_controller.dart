import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/verses/models/verse.dart';
import '../../../features/progress/services/progress_service.dart';

class PracticeController {
  final List<bool> answers = [];
  final List<String> userAnswers = [];
  final Verse verse;

  PracticeController({required this.verse, required bool isTestMode});

  static Future<PracticeController> initialize(
    Verse verse, {
    required bool isTestMode,
  }) async {
    return PracticeController(
      verse: verse,
      isTestMode: isTestMode,
    );
  }

  Future<bool> submitAnswer(
    int questionIndex,
    String userAnswer,
    String correctAnswer,
  ) async {
    final isCorrect = userAnswer.trim() == correctAnswer.trim();

    if (questionIndex >= answers.length) {
      answers.add(isCorrect);
      userAnswers.add(userAnswer);
    } else {
      answers[questionIndex] = isCorrect;
      userAnswers[questionIndex] = userAnswer;
    }

    return isCorrect;
  }

  Future<bool> submitWordOrder(
    int questionIndex,
    List<String> selectedWords,
    List<String> correctWords,
  ) async {
    final userAnswer = selectedWords.join(' ');
    final correctAnswer = correctWords.join(' ');
    return submitAnswer(questionIndex, userAnswer, correctAnswer);
  }

  Future<bool> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressService = ProgressService(prefs);

      // Calculate the score based on correct answers
      final score = answers.where((answer) => answer).length / answers.length;

      // Update progress with the test results
      await progressService.updateProgress(verse.id, answers);

      // Update the verse's progress property
      verse.progress = (score * 100).round();

      return true;
    } catch (e) {
      print('Error saving progress: $e');
      return false;
    }
  }
}
