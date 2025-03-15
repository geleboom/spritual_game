import 'package:flutter/material.dart';

abstract class PracticeStateInterface {
  void onComplete(bool shouldRefresh);
  void handleAnswer(String answer, String correctAnswer);
  void showError(String message);
  Widget buildBody();
  String getScreenTitle();
}