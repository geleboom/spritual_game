import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { am, en }

enum TopicType { faith, love, hope, peace, wisdom }

class SettingsProvider extends ChangeNotifier {
  static const double passingScore = 80.0;
  static const String _darkModeKey = 'darkMode';
  static const String _languageKey = 'language';
  static const String _fontSizeKey = 'fontSize';
  static const String _currentTabKey = 'currentTab';

  bool _isDarkMode = true;
  String _language = 'am';
  double _fontSize = 16.0;
  int _currentTab = 0;

  static final Map<String, Map<String, String>> translations = {
    'am': {
      'confirm': 'አረጋግጥ',
      'settings': 'ቅንብሮች',
      'language': 'ቋንቋ',
      'fontSize': 'የፊደል መጠን',
      'darkMode': 'ጨለማ ገጽታ',
      'chooseLanguage': 'ቋንቋ ይምረጡ',
      'amharic': 'አማርኛ',
      'english': 'English',
      'sampleText': 'ናሙና ጽሑፍ',
      'dashboard': 'ዋና ገጽ',
      'explore': 'አስስ',
      'practice': 'ልምምድ',
      'profile': 'መገለጫ',
      'edit_profile': 'መገለጫ ያስተካክሉ',
      'name': 'ስም',
      'email': 'ኢሜይል',
      'cancel': 'ሰርዝ',
      'save': 'አስቀምጥ',
      'level': 'ደረጃ',
      'beginner': 'ጀማሪ',
      'intermediate': 'መካከለኛ',
      'advanced': 'ከፍተኛ',
      'master': 'ባለሙያ',
      'level_progress': 'የደረጃ እድገት',
      'statistics': 'ስታትስቲክስ',
      'completed_verses': 'የተጠናቀቁ ጥቅሶች',
      'practice_days': 'የልምምድ ቀናት',
      'average_score': 'አማካይ ውጤት',
      'completed_references': 'የተጠናቀቁ ጥቅሶች ዝርዝር',
      'no_completed_verses': 'እስካሁን ምንም የተጠናቀቀ ጥቅስ የለም',
      'mastered_verses': 'የተካኑ ጥቅሶች',
      'verseRemoved': 'ጥቅሱ ከዳሽቦርድ ተወግዷል',
      'verseAdded': 'ጥቅሱ ወደ ዳሽቦርድ ተጨምሯል',
      'dashboardFull': 'ዳሽቦርድ ሙሉ ነው (5 ጥቅሶች)',
      'no_verses_in_dashboard': 'ምንም ጥቅሶች በዳሽቦርድ የሉም',
      'readAgain': 'እንደገና ያንብቡ',
      'remembered': 'አስታውሰዋል',
      'practiceNow': 'አሁን ይለማመዱ',
      'goToExplore': 'ወደ አስስ ይሂዱ',
      'completed': 'ተጠናቋል',
      'add_verses_dashboard_instruction':
          'ለመለማመድ ጥቅሶች፣ መጀመሪያ ከአስስ ገጽ ወደ ዳሽቦርድዎ ይጨምሩ',
      'go_to_explore': 'ወደ አስስ ሂድ',
      'error': 'ስህተት',
      'error_loading_verses': 'ጥቅሶች በመጫን ላይ ስህተት',
      'loading': 'በመጫን ላይ...',
    },
    'en': {
      'confirm': 'Confirm',
      'settings': 'Settings',
      'language': 'Language',
      'fontSize': 'Font Size',
      'darkMode': 'Dark Mode',
      'chooseLanguage': 'Choose Language',
      'amharic': 'Amharic',
      'english': 'English',
      'sampleText': 'Sample Text',
      'dashboard': 'Dashboard',
      'explore': 'Explore',
      'practice': 'Practice',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email': 'Email',
      'cancel': 'Cancel',
      'save': 'Save',
      'level': 'Level',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'master': 'Master',
      'level_progress': 'Level Progress',
      'statistics': 'Statistics',
      'completed_verses': 'Completed Verses',
      'practice_days': 'Practice Days',
      'average_score': 'Average Score',
      'completed_references': 'Completed Verses List',
      'no_completed_verses': 'No verses completed yet',
      'mastered_verses': 'Mastered Verses',
      'verseRemoved': 'Verse removed from dashboard',
      'verseAdded': 'Verse added to dashboard',
      'dashboardFull': 'Dashboard is full (5 verses)',
      'no_verses_in_dashboard': 'No verses in dashboard',
      'readAgain': 'Read Again',
      'remembered': 'Remembered',
      'practiceNow': 'Practice Now',
      'goToExplore': 'Go to Explore',
      'completed': 'completed',
      'add_verses_dashboard_instruction':
          'To practice verses, first add them to your dashboard from the Explore page',
      'go_to_explore': 'Go to Explore',
      'error': 'Error',
      'error_loading_verses': 'Error loading verses',
      'loading': 'Loading...',
    },
  };

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  double get fontSize => _fontSize;
  int get currentTab => _currentTab;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
      _language = prefs.getString(_languageKey) ?? 'am';
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;
      _currentTab = prefs.getInt(_currentTabKey) ?? 0;
      notifyListeners();
    } catch (e) {
      // Handle errors, maybe log them or show user feedback
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String value) async {
    if (_language != value) {
      _language = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, value);
      notifyListeners();
    }
  }

  Future<void> setFontSize(double value) async {
    if (_fontSize != value) {
      _fontSize = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, value);
      notifyListeners();
    }
  }

  String getTranslatedText(String key) {
    return translations[_language]?[key] ?? translations['am']![key]!;
  }

  String getTopicDescription(String topicId) {
    final descriptions = {
      'salvation': {'am': 'ድነትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about salvation'},
      'faith': {'am': 'እምነትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about faith'},
      'love': {'am': 'ፍቅርን የሚመለከቱ ጥቅሶች', 'en': 'Verses about love'},
      'hope': {'am': 'ተስፋን የሚመለከቱ ጥቅሶች', 'en': 'Verses about hope'},
      'peace': {'am': 'ሰላምን የሚመለከቱ ጥቅሶች', 'en': 'Verses about peace'},
      'wisdom': {'am': 'ጥበብን የሚመለከቱ ጥቅሶች', 'en': 'Verses about wisdom'},
      'contentment': {
        'am': 'እርካታን የሚመለከቱ ጥቅሶች',
        'en': 'Verses about contentment'
      },
      'encouragement': {
        'am': 'ማበረታታትን የሚመለከቱ ጥቅሶች',
        'en': 'Verses about encouragement'
      },
      'anger': {'am': 'ቁጣን የሚመለከቱ ጥቅሶች', 'en': 'Verses about anger'},
      'fear': {'am': 'ፍርሃትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about fear'},
      'giving': {'am': 'መስጠትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about giving'},
      'lust': {'am': 'ምኞትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about lust'},
      'pride': {'am': 'ትዕቢትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about pride'},
      'forgiveness': {
        'am': 'ምሕረትን የሚመለከቱ ጥቅሶች',
        'en': 'Verses about forgiveness'
      },
      'patience': {'am': 'ትዕግስትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about patience'},
      'prayer': {'am': 'ጸሎትን የሚመለከቱ ጥቅሶች', 'en': 'Verses about prayer'},
      'others': {'am': 'ሌሎች ጥቅሶች', 'en': 'Other verses'}
    };

    return descriptions[topicId]?[_language] ??
        descriptions[topicId]?['am'] ??
        'No description available';
  }

  ThemeData get theme {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: _fontSize),
        bodyMedium:
            baseTheme.textTheme.bodyMedium?.copyWith(fontSize: _fontSize),
        titleLarge:
            baseTheme.textTheme.titleLarge?.copyWith(fontSize: _fontSize + 4),
        titleMedium:
            baseTheme.textTheme.titleMedium?.copyWith(fontSize: _fontSize + 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        color: _isDarkMode ? Colors.black45 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> navigateToTab(int index) async {
    if (index >= 0 && index <= 4) {
      // Ensure valid tab index
      _currentTab = index;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentTabKey, index);
      notifyListeners();
    }
  }
}
