import 'package:flutter/material.dart';
import '../widgets/base_practice_widget.dart';
import '../interfaces/practice_state_interface.dart';
import '../widgets/practice_ui_components.dart';

abstract class BasePracticeState<T extends BasePracticeScreen> 
    extends State<T> implements PracticeStateInterface {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.settings.isDarkMode ? Colors.black : Colors.white,
      appBar: PracticeUIComponents.buildAppBar(
        title: getScreenTitle(),
        isDarkMode: widget.settings.isDarkMode,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: buildBody(),
      ),
    );
  }

  @override
  String getScreenTitle() => 'Practice';

  @override
  void showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void onComplete(bool shouldRefresh) {
    if (!mounted) return;
    Navigator.of(context).pop(shouldRefresh);
  }

  // Helper methods for child classes
  Widget buildLoadingIndicator() => PracticeUIComponents.buildLoadingIndicator();
  
  Widget buildVerseReference() => PracticeUIComponents.buildVerseReference(
    verse: widget.verse,
    settings: widget.settings,
  );
  
  Widget buildVerseText() => PracticeUIComponents.buildVerseText(
    verse: widget.verse,
    settings: widget.settings,
  );
}