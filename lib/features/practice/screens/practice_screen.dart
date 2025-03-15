import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiritual_game/features/practice/utils/practice_feedback_handler.dart';
import '../../verses/models/verse.dart';
import '../../settings/providers/settings_provider.dart';
import '../../practice/screens/practice_success_screen.dart';
import '../controllers/practice_controller.dart';
import '../utils/question_generator.dart';

class PracticeScreen extends StatefulWidget {
  final Verse verse;
  final String practiceMode;

  const PracticeScreen({
    Key? key,
    required this.verse,
    required this.practiceMode,
  }) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentQuestionIndex = 0;
  List<String> _selectedWords = [];
  bool _isLoading = true;
  late PracticeController _controller;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      _controller = await PracticeController.initialize(
        widget.verse,
        isTestMode: widget.practiceMode == 'test',
      );
      
      if (!mounted) return;
      
      _generateQuestions();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing practice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _generateQuestions() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final verseText = settings.language == 'am' 
        ? widget.verse.verseText 
        : widget.verse.translation;
    final verseReference = settings.language == 'am'
        ? widget.verse.reference
        : widget.verse.referenceTranslation;

    if (widget.practiceMode == 'test') {
      _questions = QuestionGenerator.generateTestQuestions(verseText, verseReference, settings.language)
          .map((testQ) => Question(
                text: testQ.question,
                type: QuestionType.multipleChoice,
                options: testQ.options,
                correctAnswer: testQ.options[testQ.correctAnswerIndex],
              ))
          .toList();
    } else {
      switch (widget.practiceMode) {
        case 'read':
          _questions = [await QuestionGenerator.generateWordOrderQuestion(verseText, settings.language)];
          break;
        case 'blank':
          final blankQuestion = await QuestionGenerator.generateBlankQuestion(verseText, settings.language);
          _questions = [Question(
            text: blankQuestion.text,
            type: QuestionType.fillInBlank,
            options: blankQuestion.options,
            correctAnswer: blankQuestion.correctAnswer,
          )];
          break;
        case 'type':
          _questions = [QuestionGenerator.generateTypingQuestion(verseText, settings.language)];
          break;
        default:
          _questions = [await QuestionGenerator.generateWordOrderQuestion(verseText, settings.language)];
      }
    }
  }

  void _checkAnswer(String answer) async {
    final currentQuestion = _questions[_currentQuestionIndex];

    if (currentQuestion.type == QuestionType.wordOrder) {
      setState(() {
        _selectedWords.add(answer);
      });
      return;
    }

    final isCorrect = await _controller.submitAnswer(
      _currentQuestionIndex,
      answer,
      currentQuestion.correctAnswer,
    );

    if (!mounted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    PracticeFeedbackHandler.showAnswerFeedback(
      context: context,
      isCorrect: isCorrect,
      correctAnswer: currentQuestion.correctAnswer,
      settings: settings,
      onFeedbackClosed: () {
        if (mounted) {
          setState(() {
            if (_currentQuestionIndex < _questions.length - 1) {
              _currentQuestionIndex++;
              if (_questions[_currentQuestionIndex].type == QuestionType.wordOrder) {
                _selectedWords = [];
              }
            } else {
              _showResults();
            }
          });
        }
      },
    );
  }

  void _submitWordOrder() async {
    final currentQuestion = _questions[_currentQuestionIndex];
    final words = currentQuestion.correctAnswer.split(' ');

    final isCorrect = await _controller.submitWordOrder(
      _currentQuestionIndex,
      _selectedWords,
      words,
    );

    if (!mounted) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    PracticeFeedbackHandler.showWordOrderFeedback(
      context: context,
      isCorrect: isCorrect,
      settings: settings,
      onFeedbackClosed: () {
        if (mounted) {
          if (_currentQuestionIndex < _questions.length - 1) {
            setState(() {
              _currentQuestionIndex++;
              _selectedWords = [];
            });
          } else {
            _showLoadingAndNavigate();
          }
        }
      },
    );
  }

  Future<void> _showLoadingAndNavigate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final shouldRefresh = await _controller.saveProgress();
    
    if (!mounted) return;
    
    Navigator.of(context).pop();

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSuccessScreen(
          verse: widget.verse,
          answers: _controller.answers,
          userAnswers: _controller.userAnswers,
          questions: _questions,
          isTestMode: widget.practiceMode == 'test',
          shouldRefresh: shouldRefresh,
        ),
      ),
    );
  }

  Future<void> _showResults() async {
    if (!mounted) return;

    final shouldRefresh = await _controller.saveProgress();
    
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSuccessScreen(
          verse: widget.verse,
          answers: _controller.answers,
          userAnswers: _controller.userAnswers,
          questions: _questions,
          isTestMode: widget.practiceMode == 'test',
          shouldRefresh: shouldRefresh,
        ),
      ),
    );

    if (shouldRefresh && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final translations = SettingsProvider.translations[settings.language] ??
            SettingsProvider.translations['am']!;

        if (_isLoading) {
          return Scaffold(
            backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.popUntil(
                  context,
                  (route) => route.settings.name == 'practice_style_screen' || route.isFirst,
                ),
              ),
              title: Text(
                translations['practice'] ?? 'ልምምድ',
                style: TextStyle(
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                  fontSize: settings.fontSize,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentQuestion = _questions[_currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(translations['practice'] ?? 'ልምምድ'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: settings.isDarkMode
                    ? [Colors.black87, Colors.black]
                    : [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor:
                      settings.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    settings.isDarkMode ? Colors.white : Colors.blue,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.language == 'am'
                              ? 'ጥያቄ ${_currentQuestionIndex + 1}/${_questions.length}'
                              : 'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: settings.fontSize,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentQuestion.text,
                          style: TextStyle(
                            fontSize: settings.fontSize + 2,
                            height: 1.5,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildQuestionOptions(currentQuestion, settings),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionOptions(Question currentQuestion, SettingsProvider settings) {
    if (currentQuestion.type == QuestionType.wordOrder) {
      return Expanded(
        child: Column(
          children: [
            // Selected words
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedWords.asMap().entries.map((entry) {
                return Chip(
                  label: Text(
                    entry.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: settings.fontSize,
                    ),
                  ),
                  backgroundColor: Colors.blue,
                  onDeleted: () {
                    setState(() {
                      _selectedWords.removeAt(entry.key);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Available words
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: currentQuestion.options
                    .where((word) => !_selectedWords.contains(word))
                    .map((word) {
                  return ElevatedButton(
                    onPressed: () => _checkAnswer(word),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(fontSize: settings.fontSize),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_selectedWords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitWordOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    settings.language == 'am' ? 'አስገባ' : 'Submit',
                    style: TextStyle(fontSize: settings.fontSize),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: currentQuestion.options.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _checkAnswer(currentQuestion.options[index]),
                child: Text(
                  currentQuestion.options[index],
                  style: TextStyle(fontSize: settings.fontSize),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void _removeWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
    });
  }
}

enum QuestionType {
  multipleChoice,
  fillInBlank,
  wordOrder,
  typing,  // Add this new type
}

class Question {
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
  });
}

