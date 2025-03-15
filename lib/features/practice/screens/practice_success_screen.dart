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
  final bool isTestMode;
  final bool shouldRefresh;

  const PracticeSuccessScreen({
    Key? key,
    required this.verse,
    required this.answers,
    required this.userAnswers,
    required this.questions,
    this.isTestMode = false,
    this.shouldRefresh = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(shouldRefresh);
        return false;
      },
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final translations = SettingsProvider.translations[settings.language] ??
              SettingsProvider.translations['am']!;
          final score = answers.where((answer) => answer).length;
          final percentage = (score / answers.length * 100).round();
          final isPassed = percentage >= 80;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPassed ? Icons.star : Icons.star_border,
                      size: 64,
                      color: isPassed ? Colors.amber : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isTestMode
                          ? (isPassed
                              ? (settings.language == 'am'
                                  ? 'ፈተናውን በተሳካ ሁኔታ አልፈዋል!'
                                  : 'Test Passed Successfully!')
                              : (settings.language == 'am'
                                  ? 'እባክዎ እንደገና ይሞክሩ'
                                  : 'Please Try Again'))
                          : (settings.language == 'am'
                              ? 'ልምምዱን አጠናቀዋል!'
                              : 'Practice Complete!'),
                      style: TextStyle(
                        fontSize: settings.fontSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${translations['score']}: $percentage%',
                      style: TextStyle(
                        fontSize: settings.fontSize + 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isTestMode && isPassed) ...[
                      const SizedBox(height: 16),
                      Text(
                        settings.language == 'am'
                            ? 'እንኳን ደስ አለዎት! XP አግኝተዋል!'
                            : 'Congratulations! You earned XP!',
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pop back to practice mode selection
                          Navigator.of(context).pop(shouldRefresh);
                          Navigator.of(context).pop(); // Pop one more time to return to practice mode selection
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          settings.language == 'am' ? 'ተመለስ' : 'Back to Practice',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


