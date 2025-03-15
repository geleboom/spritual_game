import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_game/features/settings/providers/settings_provider.dart';
import 'package:spiritual_game/features/progress/services/progress_service.dart';
import 'package:spiritual_game/features/profile/models/user_profile.dart';
import '../../base/index.dart';
import '../../models/test_question.dart';
import '../../utils/question_generator.dart';
import 'dart:convert';

class TestModeScreen extends BasePracticeScreen {
  const TestModeScreen({
    super.key,
    required super.verse,
    required super.settings,
  });

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends BasePracticeState<TestModeScreen> {
  late final List<TestQuestion> _questions;
  int _currentQuestionIndex = 0;
  late final List<int?> _userAnswers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    final String text = widget.settings.language == 'am'
        ? widget.verse.verseText
        : widget.verse.translation;
    final String reference = widget.settings.language == 'am'
        ? widget.verse.reference
        : widget.verse.referenceTranslation;

    _questions = QuestionGenerator.generateTestQuestions(
      text,
      reference,
      widget.settings.language,
    );
    _userAnswers = List<int?>.filled(_questions.length, null);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleOptionSelected(int optionIndex) {
    if (_userAnswers[_currentQuestionIndex] != null) return;

    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        _calculateAndComplete();
      }
    });
  }

  Future<void> _calculateAndComplete() async {
    int correctAnswers = 0;
    List<bool> results = [];

    for (int i = 0; i < _questions.length; i++) {
      final isCorrect =
          _userAnswers[i] != null && _questions[i].isCorrect(_userAnswers[i]!);
      if (isCorrect) {
        correctAnswers++;
      }
      results.add(isCorrect);
    }

    final score = (correctAnswers / _questions.length) * 100;

    // Save progress
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressService = ProgressService(prefs);

      // Save progress with mode
      await progressService.updateProgress(widget.verse.id, results,
          mode: 'test');

      // Update verse progress
      widget.verse.progress = score.round();

      // If test is passed (score >= passing score), update user profile
      if (score >= SettingsProvider.passingScore) {
        final userProfileJson = prefs.getString('user_profile');
        if (userProfileJson != null) {
          final userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));
          if (!userProfile.completedVerses.contains(widget.verse.id)) {
            userProfile.completedVerses.add(widget.verse.id);
            await prefs.setString(
                'user_profile', jsonEncode(userProfile.toJson()));
            print(
                'Added verse ${widget.verse.id} to completed verses in profile after passing test');
          }
        }
      }

      print('Test completed with score: $score%');
      print('Results: $results');
    } catch (e) {
      print('Error saving test progress: $e');
    }

    onComplete(score >= SettingsProvider.passingScore);
  }

  @override
  String getScreenTitle() => widget.settings.language == 'am' ? 'ፈተና' : 'Test';

  @override
  void handleAnswer(String answer, String correctAnswer) {
    // Not used in test mode
  }

  Widget _buildQuestionCard(TestQuestion question) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: TextStyle(
                fontSize: widget.settings.fontSize,
                fontWeight: FontWeight.bold,
                color:
                    widget.settings.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              final int index = entry.key;
              final String option = entry.value;
              final bool isSelected =
                  _userAnswers[_currentQuestionIndex] == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : null,
                    foregroundColor: isSelected ? Colors.white : null,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _handleOptionSelected(index),
                  child: Text(
                    option,
                    style: TextStyle(fontSize: widget.settings.fontSize - 2),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${_currentQuestionIndex + 1}/${_questions.length}',
            style: TextStyle(
              fontSize: 16,
              color: widget.settings.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          _buildProgress(),
          buildVerseReference(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildQuestionCard(_questions[_currentQuestionIndex]),
            ),
          ),
        ],
      ),
    );
  }
}
