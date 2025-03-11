import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/verses/models/verse.dart';
import '../../../features/progress/services/progress_service.dart';

class PracticeController {
  final Verse verse;
  final ProgressService progressService;
  final List<bool> answers;
  final List<String> userAnswers;

  PracticeController({
    required this.verse,
    required this.progressService,
    required this.answers,
    required this.userAnswers,
  });

  static Future<PracticeController> initialize(Verse verse) async {
    final prefs = await SharedPreferences.getInstance();
    final progressService = ProgressService(prefs);

    return PracticeController(
      verse: verse,
      progressService: progressService,
      answers: [],
      userAnswers: [],
    );
  }

  // Check multiple choice or fill in blank answer
  bool checkAnswer(String userAnswer, String correctAnswer) {
    return userAnswer == correctAnswer;
  }

  // Check word order answer
  bool checkWordOrder(List<String> selectedWords, List<String> correctWords) {
    if (selectedWords.length != correctWords.length) return false;

    final selectedString = selectedWords.join(' ');
    final correctString = correctWords.join(' ');
    return selectedString == correctString;
  }

  // Submit answer and get result
  Future<bool> submitAnswer(
      int questionIndex, String answer, String correctAnswer) async {
    final isCorrect = checkAnswer(answer, correctAnswer);

    // Update answers list
    if (questionIndex >= answers.length) {
      answers.add(isCorrect);
      userAnswers.add(answer);
    } else {
      answers[questionIndex] = isCorrect;
      userAnswers[questionIndex] = answer;
    }

    return isCorrect;
  }

  // Submit word order answer
  Future<bool> submitWordOrder(int questionIndex, List<String> selectedWords,
      List<String> correctWords) async {
    final isCorrect = checkWordOrder(selectedWords, correctWords);
    final answer = selectedWords.join(' ');

    // Update answers list
    if (questionIndex >= answers.length) {
      answers.add(isCorrect);
      userAnswers.add(answer);
    } else {
      answers[questionIndex] = isCorrect;
      userAnswers[questionIndex] = answer;
    }

    return isCorrect;
  }

  // Save progress
  Future<void> saveProgress() async {
    await progressService.updateProgress(verse.id, answers);
  }

  // Get final score
  int getScore() {
    return answers.where((answer) => answer).length;
  }

  // Check if all questions are answered
  bool isComplete() {
    return answers.length == 3; // Since we have 3 questions
  }
}
