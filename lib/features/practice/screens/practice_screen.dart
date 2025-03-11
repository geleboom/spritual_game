import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../verses/models/verse.dart';
import '../../settings/providers/settings_provider.dart';
import '../../practice/screens/practice_success_screen.dart';
import '../controllers/practice_controller.dart';

class PracticeScreen extends StatefulWidget {
  final Verse verse;

  const PracticeScreen({Key? key, required this.verse}) : super(key: key);

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
    _controller = await PracticeController.initialize(widget.verse);
    _generateQuestions();
    setState(() {
      _isLoading = false;
    });
  }

  void _generateQuestions() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final verseText = settings.getVerseText(widget.verse.id);
    final verseReference = settings.getVerseReference(widget.verse.id);
    final words = verseText.split(' ');

    _questions = [
      Question(
        text: settings.language == 'am'
            ? 'የትኛው የመጽሐፍ ቅዱስ ጥቅስ ነው?'
            : 'Which Bible verse is this?',
        type: QuestionType.multipleChoice,
        options: [
          verseReference,
          'ዮሐንስ 1:1',
          'ማቴዎስ 5:16',
          'መዝሙር 119:105',
        ],
        correctAnswer: verseReference,
      ),
      Question(
        text: settings.language == 'am'
            ? 'ባዶውን ቦታ ሙሉ:\n${verseText.replaceAll(words[2], '_____')}'
            : 'Fill in the blank:\n${verseText.replaceAll(words[2], '_____')}',
        type: QuestionType.fillInBlank,
        options: [words[2], words[4], words[1], words[3]],
        correctAnswer: words[2],
      ),
      Question(
        text: settings.language == 'am'
            ? 'ቃላቱን በትክክለኛው ቅደም ተከተል ያስቀምጡ:'
            : 'Put the words in the correct order:',
        type: QuestionType.wordOrder,
        options: List<String>.from(words.sublist(0, 4))..shuffle(),
        correctAnswer: words.sublist(0, 4).join(' '),
      ),
    ];
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

  void _submitWordOrder() async {
    final currentQuestion = _questions[_currentQuestionIndex];
    final words = currentQuestion.correctAnswer.split(' ');

    final isCorrect = await _controller.submitWordOrder(
      _currentQuestionIndex,
      _selectedWords,
      words,
    );

    // Save progress and navigate to success screen
    if (mounted) {
      await _controller.saveProgress();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeSuccessScreen(
            verse: widget.verse,
            answers: _controller.answers,
            userAnswers: _controller.userAnswers,
            questions: _questions,
          ),
        ),
      );
    }
  }

  Future<void> _showResults() async {
    if (!mounted) return;

    await _controller.saveProgress();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSuccessScreen(
          verse: widget.verse,
          answers: _controller.answers,
          userAnswers: _controller.userAnswers,
          questions: _questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                        color:
                            settings.isDarkMode ? Colors.white : Colors.black87,
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
  }

  Widget _buildQuestionOptions(Question currentQuestion, AppSettings settings) {
    if (currentQuestion.type == QuestionType.wordOrder) {
      return _buildWordOrderOptions(currentQuestion, settings);
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
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildWordOrderOptions(
      Question currentQuestion, AppSettings settings) {
    return Expanded(
      child: Column(
        children: [
          // Selected words area
          if (_selectedWords.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    settings.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedWords.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(
                      entry.value,
                      style: TextStyle(fontSize: settings.fontSize),
                    ),
                    onDeleted: () => _removeWord(entry.key),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),

          // Available words area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: settings.isDarkMode ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currentQuestion.options
                  .where((word) => !_selectedWords.contains(word))
                  .map((word) {
                return ActionChip(
                  label: Text(
                    word,
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      color:
                          settings.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedWords.add(word);
                    });
                  },
                  backgroundColor:
                      settings.isDarkMode ? Colors.grey[800] : Colors.white,
                );
              }).toList(),
            ),
          ),
          const Spacer(),

          // Confirm button area
          if (_selectedWords.isNotEmpty) ...[
            Text(
              settings.language == 'am'
                  ? 'ሁሉንም ቃላት ይምረጡ እና ያረጋግጡ'
                  : 'Select all words and confirm',
              style: TextStyle(
                fontSize: settings.fontSize,
                color: settings.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedWords.length == currentQuestion.options.length
                        ? () {
                            // Show loading indicator while processing
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            // Submit answer and navigate
                            _submitWordOrder();
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppSettings.translations[settings.language]?['confirm'] ??
                      'አረጋግጥ',
                  style: TextStyle(
                    fontSize: settings.fontSize + 2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
