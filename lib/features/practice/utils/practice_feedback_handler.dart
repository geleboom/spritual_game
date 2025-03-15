import 'package:flutter/material.dart';
import '../../settings/providers/settings_provider.dart';

class PracticeFeedbackHandler {
  static void showAnswerFeedback({
    required BuildContext context,
    required bool isCorrect,
    required String correctAnswer,
    required SettingsProvider settings,
    VoidCallback? onFeedbackClosed,
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? (settings.language == 'am' ? 'ትክክል!' : 'Correct!')
              : (settings.language == 'am'
                  ? 'ትክክለኛው መልስ: $correctAnswer'
                  : 'Correct answer: $correctAnswer'),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        onVisible: () {
          // Wait for feedback to be shown before proceeding
          Future.delayed(
            const Duration(seconds: 1),
            () => onFeedbackClosed?.call(),
          );
        },
      ),
    );
  }

  static void showWordOrderFeedback({
    required BuildContext context,
    required bool isCorrect,
    required SettingsProvider settings,
    VoidCallback? onFeedbackClosed,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? (settings.language == 'am' ? 'ትክክል!' : 'Correct!')
              : (settings.language == 'am'
                  ? 'እባክዎ እንደገና ይሞክሩ'
                  : 'Please try again'),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        onVisible: () {
          Future.delayed(
            const Duration(seconds: 1),
            () => onFeedbackClosed?.call(),
          );
        },
      ),
    );
  }

  static Future<void> showBlankFeedback({
    required BuildContext context,
    required bool isCorrect,
    required List<String> correctAnswers,
    required SettingsProvider settings,
    VoidCallback? onFeedbackClosed,
  }) async {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? (settings.language == 'am' ? 'ትክክል!' : 'Correct!')
              : (settings.language == 'am'
                  ? 'ትክክለኛው መልስ: ${correctAnswers.join(", ")}'
                  : 'Correct answers: ${correctAnswers.join(", ")}'),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        onVisible: () {
          // Wait for feedback to be shown before proceeding
          Future.delayed(
            const Duration(seconds: 2),
            () {
              if (context.mounted) {
                onFeedbackClosed?.call();
              }
            },
          );
        },
      ),
    );
  }
}
