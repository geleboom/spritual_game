import 'package:flutter/material.dart';
import '../../../features/verses/models/verse.dart';
import '../../../features/settings/providers/settings_provider.dart';

class PracticeUIComponents {
  static PreferredSizeWidget buildAppBar({
    required String title,
    required bool isDarkMode,
    required VoidCallback? onBack,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      leading: onBack != null ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ) : null,
    );
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildVerseReference({
    required Verse verse,
    required SettingsProvider settings,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        settings.language == 'am'
            ? verse.reference
            : verse.referenceTranslation,
        style: TextStyle(
          fontSize: settings.fontSize + 4,
          fontWeight: FontWeight.bold,
          color: settings.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  static Widget buildVerseText({
    required Verse verse,
    required SettingsProvider settings,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        settings.language == 'am'
            ? verse.verseText
            : verse.translation,
        style: TextStyle(
          fontSize: settings.fontSize,
          color: settings.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}