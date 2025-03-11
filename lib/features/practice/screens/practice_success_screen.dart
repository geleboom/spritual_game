import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../verses/models/verse.dart';
import 'practice_screen.dart';

class PracticeSuccessScreen extends StatelessWidget {
  final Verse verse;
  final List<bool> answers;
  final List<String> userAnswers;
  final List<Question> questions;

  const PracticeSuccessScreen({
    Key? key,
    required this.verse,
    required this.answers,
    required this.userAnswers,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;
    final score = answers.where((answer) => answer).length;
    final percentage = (score / answers.length * 100).round();

    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Icon(
                  percentage >= 80 ? Icons.stars : Icons.star_half,
                  size: 80,
                  color: percentage >= 80 ? Colors.amber : Colors.blue,
                ),
                const SizedBox(height: 24),

                // Congratulations text
                Text(
                  percentage >= 80
                      ? translations['congratulations']!
                      : translations['goodTry']!,
                  style: TextStyle(
                    fontSize: settings.fontSize + 8,
                    fontWeight: FontWeight.bold,
                    color: settings.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Score text
                Text(
                  translations['correctAnswers']!
                      .replaceAll('{total}', answers.length.toString())
                      .replaceAll('{correct}', score.toString()),
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    color:
                        settings.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Progress bar
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: settings.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: score / answers.length,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: percentage >= 80
                              ? [Colors.amber, Colors.orange]
                              : [Colors.blue, Colors.blue.shade700],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PracticeScreen(verse: verse),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          translations['tryAgain']!,
                          style: TextStyle(fontSize: settings.fontSize),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _showDetailedResults(context, settings, translations);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: BorderSide(
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          translations['detailed_results']!,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        translations['finish']!,
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: settings.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailedResults(BuildContext context, AppSettings settings,
      Map<String, String> translations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.isDarkMode ? Colors.black87 : Colors.white,
        title: Text(
          translations['detailed_results']!,
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : Colors.black87,
            fontSize: settings.fontSize + 4,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(questions.length, (index) {
              final question = questions[index];
              final isCorrect = answers[index];
              final userAnswer = userAnswers[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translations['question']} ${index + 1}:',
                      style: TextStyle(
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: settings.fontSize - 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.text,
                      style: TextStyle(
                        color:
                            settings.isDarkMode ? Colors.white : Colors.black87,
                        fontSize: settings.fontSize - 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${translations['your_answer']}: $userAnswer',
                                style: TextStyle(
                                  color: settings.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: settings.fontSize - 2,
                                ),
                              ),
                              if (!isCorrect)
                                Text(
                                  '${translations['correct_answer']}: ${question.correctAnswer}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: settings.fontSize - 2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              translations['finish']!,
              style: TextStyle(fontSize: settings.fontSize),
            ),
          ),
        ],
      ),
    );
  }
}
