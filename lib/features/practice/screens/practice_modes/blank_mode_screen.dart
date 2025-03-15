import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_game/features/progress/services/progress_service.dart';
import 'package:spiritual_game/features/profile/models/user_profile.dart';
import 'dart:convert';
import '../../base/index.dart';
import '../../models/question.dart' as models;
import '../../screens/practice_screen.dart' as practice_screen;
import '../../utils/question_generator.dart';
import 'package:spiritual_game/features/practice/utils/practice_feedback_handler.dart';

class BlankModeScreen extends BasePracticeScreen {
  const BlankModeScreen({
    Key? key,
    required super.verse,
    required super.settings,
  }) : super(key: key);

  @override
  State<BlankModeScreen> createState() => _BlankModeScreenState();
}

class _BlankModeScreenState extends BasePracticeState<BlankModeScreen> {
  final List<TextEditingController> _blankControllers = [];
  List<models.Question> _questions = [];
  final int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  Future<void> _initializeQuestions() async {
    final verseText = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;

    _questions = [
      await QuestionGenerator.generateBlankQuestion(
          verseText, widget.settings.language)
    ];
    _initializeControllers();

    if (mounted) {
      setState(() {});
    }
  }

  void _initializeControllers() {
    // Clear existing controllers
    for (var controller in _blankControllers) {
      controller.dispose();
    }
    _blankControllers.clear();

    // Create new controllers for each blank
    if (_questions.isNotEmpty) {
      final currentQuestion = _questions[0];
      for (var _ in currentQuestion.options) {
        _blankControllers.add(TextEditingController());
      }
    }
  }

  @override
  Widget buildBody() {
    if (_questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildVerseReference(),
          Expanded(
            child: _buildQuestionContent(_questions[_currentQuestionIndex]),
          ),
          // Add navigation buttons at the bottom
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      const SizedBox(width: 8),
                      Text(
                        widget.settings.language == 'am' ? 'ተመለስ' : 'Back',
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _initializeQuestions();
                    for (var controller in _blankControllers) {
                      controller.clear();
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(width: 8),
                      Text(
                        widget.settings.language == 'am'
                            ? 'እንደገና ሞክር'
                            : 'Try Again',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(models.Question currentQuestion) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion.text,
                  style: TextStyle(
                    fontSize: widget.settings.fontSize + 2,
                    color: widget.settings.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(currentQuestion.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _blankControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Blank ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: widget.settings.isDarkMode
                            ? Colors.grey[900]
                            : Colors.grey[100],
                      ),
                      style: TextStyle(
                        fontSize: widget.settings.fontSize,
                        color: widget.settings.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkBlankAnswers,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.settings.language == 'am' ? 'አረጋግጥ' : 'Check',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkBlankAnswers() async {
    if (!mounted) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final answers =
        _blankControllers.map((controller) => controller.text.trim()).toList();
    final correctAnswers = currentQuestion.options;
    bool allCorrect = true;

    for (int i = 0; i < answers.length; i++) {
      if (answers[i].toLowerCase() != correctAnswers[i].toLowerCase()) {
        allCorrect = false;
        break;
      }
    }

    print('Blank mode answers check:');
    print('Answers: $answers');
    print('Correct answers: $correctAnswers');
    print('All correct: $allCorrect');

    // Show feedback
    await PracticeFeedbackHandler.showBlankFeedback(
      context: context,
      isCorrect: allCorrect,
      correctAnswers: correctAnswers,
      settings: widget.settings,
      onFeedbackClosed: () async {
        if (!mounted) return;

        // Only proceed if all answers are correct
        if (allCorrect) {
          try {
            print('Saving blank mode progress for verse ${widget.verse.id}');

            // Update verse progress to 100%
            widget.verse.progress = 100;

            // Save progress to persistent storage
            final prefs = await SharedPreferences.getInstance();
            final progressService = ProgressService(prefs);
            await progressService.updateProgress(widget.verse.id, [true],
                mode: 'blank');

            // Update user profile with completed verse
            final userProfileJson = prefs.getString('user_profile');
            if (userProfileJson != null) {
              final userProfile =
                  UserProfile.fromJson(jsonDecode(userProfileJson));
              if (!userProfile.completedVerses.contains(widget.verse.id)) {
                userProfile.completedVerses.add(widget.verse.id);
                await prefs.setString(
                    'user_profile', jsonEncode(userProfile.toJson()));
                print(
                    'Added verse ${widget.verse.id} to completed verses in profile');
              }
            }

            // Show completion message
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: widget.settings.isDarkMode
                    ? Colors.grey[900]
                    : Colors.white,
                title: Text(
                  widget.settings.language == 'am'
                      ? 'እንኳን ደስ አለዎት!'
                      : 'Congratulations!',
                  style: TextStyle(
                    color: widget.settings.isDarkMode
                        ? Colors.white
                        : Colors.black,
                    fontSize: widget.settings.fontSize + 4,
                  ),
                ),
                content: Text(
                  widget.settings.language == 'am'
                      ? 'ሁሉንም ባዶ ቦታዎች በትክክል ሞልተዋል!'
                      : 'You have successfully completed all blanks!',
                  style: TextStyle(
                    color: widget.settings.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                    fontSize: widget.settings.fontSize,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                    child: Text(
                      widget.settings.language == 'am' ? 'ቀጥል' : 'Continue',
                      style: TextStyle(fontSize: widget.settings.fontSize),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to practice screen
                    },
                    child: Text(
                      widget.settings.language == 'am' ? 'ተመለስ' : 'Back',
                      style: TextStyle(fontSize: widget.settings.fontSize),
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            print('Error saving blank mode progress: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.settings.language == 'am'
                      ? 'የሚያዝያ ስህተት ተከስቷል'
                      : 'An error occurred while saving progress',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  @override
  String getScreenTitle() =>
      widget.settings.language == 'am' ? 'ባዶ ቦታ' : 'Fill in the Blanks';

  @override
  Future<bool> handleAnswer(String answer, String correctAnswer) async {
    return answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }

  @override
  List<practice_screen.Question> getQuestions() {
    return _questions
        .map((q) => practice_screen.Question(
              text: q.text,
              type: practice_screen.QuestionType.fillInBlank,
              options: q.options,
              correctAnswer: q.correctAnswer,
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _blankControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
