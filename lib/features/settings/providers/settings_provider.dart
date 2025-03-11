import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _languageKey = 'language';
  static const String _fontSizeKey = 'fontSize';

  bool _isDarkMode = true;
  String _language = 'am';
  double _fontSize = 16.0;

  static final Map<String, Map<String, String>> translations = {
    'am': {
      'settings': 'ቅንብሮች',
      'language': 'ቋንቋ',
      'fontSize': 'የፊደል መጠን',
      'darkMode': 'ጨለማ ገጽታ',
      'chooseLanguage': 'ቋንቋ ይምረጡ',
      'amharic': 'አማርኛ',
      'english': 'English',
      'sampleText': 'ናሙና ጽሑፍ',
      'practice': 'ልምምድ',
      'confirm': 'አረጋግጥ',
      'tryAgain': 'እንደገና ሞክር',
      'finish': 'ጨርስ',
      'congratulations': 'እንኳን ደስ አለዎት! 🎉',
      'goodTry': 'ጥሩ ጥረት! 💪',
      'correctAnswers': 'ከ{total} ውስጥ {correct} ጥያቄዎችን በትክክል መልሰዋል',
      'dashboard': 'ዳሽቦርድ',
      'explore': 'አስስ',
      'verseAdded': 'ጥቅሱ ወደ ዳሽቦርድ ተጨምሯል',
      'verseRemoved': 'ጥቅሱ ከዳሽቦርድ ተወግዷል',
      'screensaver': 'ስክሪን ሴቨር',
      'tap_to_navigate': 'ወደ ግራ/ቀኝ ለማንቀሳቀስ ይንኩ • ለመውጣት ESC ይጫኑ',
      'remembered': 'አስታውሰዋል',
      // Topics
      'anger': 'ቁጣ',
      'contentment': 'እርካታ',
      'encouragement': 'ማበረታታት',
      'faith': 'እምነት',
      'fear': 'ፍርሃት',
      'giving': 'መስጠት',
      'love': 'ፍቅር',
      'lust': 'ምኞት',
      'pride': 'ትዕቢት',
      'others': 'ሌሎች',
      // Verses descriptions
      'anger_desc': 'ስለ ቁጣ እና እንዴት መቆጣጠር እንደሚቻል የሚናገሩ ጥቅሶች',
      'contentment_desc': 'ስለ እርካታ እና መረጋጋት የሚናገሩ ጥቅሶች',
      'encouragement_desc': 'የሚያበረታቱ እና ተስፋ የሚሰጡ ጥቅሶች',
      'faith_desc': 'ስለ እምነት የሚናገሩ ጥቅሶች',
      'fear_desc': 'ፍርሃትን እንዴት ማሸነፍ እንደሚቻል የሚናገሩ ጥቅሶች',
      'giving_desc': 'ስለ መስጠት እና ለጋስነት የሚናገሩ ጥቅሶች',
      'love_desc': 'ስለ ፍቅር የሚናገሩ ጥቅሶች',
      'lust_desc': 'ስለ ምኞት እና እንዴት መቋቋም እንደሚቻል የሚናገሩ ጥቅሶች',
      'pride_desc': 'ስለ ትዕቢት እና ትሁትነት የሚናገሩ ጥቅሶች',
      'others_desc': 'ሌሎች ጠቃሚ ጥቅሶች',
      'completed': 'ተጠናቅቋል',
      'no_verses_in_dashboard': 'ምንም ጥቅሶች በዳሽቦርድ የሉም',
      'detailed_results': 'የዝርዝር ውጤቶች:',
      'question': 'ጥያቄ',
      'your_answer': 'የእርስዎ መልስ',
      'correct_answer': 'ትክክለኛው መልስ',
      'practice_verse': 'ጥቅሱን ይለማመዱ',
      'practice_complete': 'ልምምዱን አጠናቅቀዋል',
      'practice_progress': 'የልምምድ እድገት',
      'profile': 'መገለጫ',
      'student': 'ተማሪ',
      'statistics': 'ስታትስቲክስ',
      'completed_verses': 'የተጠናቀቁ ጥቅሶች',
      'practice_days': 'የልምምድ ቀናት',
      'average_score': 'አማካይ ውጤት',
      'edit_profile': 'መገለጫ ያስተካክሉ',
      'name': 'ስም',
      'email': 'ኢሜይል',
      'save': 'አስቀምጥ',
      'cancel': 'ሰርዝ',
      'level': 'ደረጃ',
      'next_level': 'ቀጣይ ደረጃ',
      'experience': 'ልምድ',
      'beginner': 'ጀማሪ',
      'intermediate': 'መካከለኛ',
      'advanced': 'የላቀ',
      'expert': 'ባለሙያ',
      'master': 'ማስተር',
      'level_progress': 'የደረጃ እድገት',
      'completed_references': 'የተጠናቀቁ ጥቅሶች ዝርዝር',
      'no_completed_verses': 'እስካሁን ምንም ጥቅሶች አልተጠናቀቁም',
      'mastered_verses': 'የተካኑ ጥቅሶች',
      'verse_progress': 'የጥቅስ እድገት',
    },
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'fontSize': 'Font Size',
      'darkMode': 'Dark Mode',
      'chooseLanguage': 'Choose Language',
      'amharic': 'Amharic',
      'english': 'English',
      'sampleText': 'Sample Text',
      'practice': 'Practice',
      'confirm': 'Confirm',
      'tryAgain': 'Try Again',
      'finish': 'Finish',
      'congratulations': 'Congratulations! 🎉',
      'goodTry': 'Good Try! 💪',
      'correctAnswers': 'You got {correct} out of {total} questions correct',
      'dashboard': 'Dashboard',
      'explore': 'Explore',
      'verseAdded': 'Verse added to dashboard',
      'verseRemoved': 'Verse removed from dashboard',
      'screensaver': 'Screensaver',
      'tap_to_navigate': 'Tap left/right to navigate • Press ESC to exit',
      'remembered': 'Remembered',
      // Topics
      'anger': 'Anger',
      'contentment': 'Contentment',
      'encouragement': 'Encouragement',
      'faith': 'Faith',
      'fear': 'Fear',
      'giving': 'Giving',
      'love': 'Love',
      'lust': 'Lust',
      'pride': 'Pride',
      'others': 'Others',
      // Verses descriptions
      'anger_desc': 'Verses about anger and how to control it',
      'contentment_desc': 'Verses about contentment and peace',
      'encouragement_desc': 'Encouraging and hopeful verses',
      'faith_desc': 'Verses about faith',
      'fear_desc': 'Verses about overcoming fear',
      'giving_desc': 'Verses about giving and generosity',
      'love_desc': 'Verses about love',
      'lust_desc': 'Verses about lust and how to overcome it',
      'pride_desc': 'Verses about pride and humility',
      'others_desc': 'Other helpful verses',
      'completed': 'completed',
      'no_verses_in_dashboard': 'No verses in dashboard',
      'detailed_results': 'Detailed Results:',
      'question': 'Question',
      'your_answer': 'Your Answer',
      'correct_answer': 'Correct Answer',
      'practice_verse': 'Practice Verse',
      'practice_complete': 'Practice Complete',
      'practice_progress': 'Practice Progress',
      'profile': 'Profile',
      'student': 'Student',
      'statistics': 'Statistics',
      'completed_verses': 'Completed Verses',
      'practice_days': 'Practice Days',
      'average_score': 'Average Score',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'email': 'Email',
      'save': 'Save',
      'cancel': 'Cancel',
      'level': 'Level',
      'next_level': 'Next Level',
      'experience': 'Experience',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'expert': 'Expert',
      'master': 'Master',
      'level_progress': 'Level Progress',
      'completed_references': 'Completed Verses List',
      'no_completed_verses': 'No verses completed yet',
      'mastered_verses': 'Mastered Verses',
      'verse_progress': 'Verse Progress',
    },
  };

  // Verses data with translations
  static final Map<String, Map<int, Map<String, String>>> versesTranslations = {
    'am': {
      1: {
        'reference': 'ዮሐንስ 3:16',
        'text':
            'እግዚአብሔር ለዓለም እንዲህ ያለ ፍቅር እንዳለው፥ የገዛ ልጁን እስከ መስጠት ድረስ ፈቀደ፤ ይህም የሚያምን ሁሉ የዘላለም ሕይወት እንዲኖረው ነው እንጂ እንዳይጠፋ ነው።',
      },
      2: {
        'reference': 'መዝሙር 23:1',
        'text': 'እግዚአብሔር እረኛዬ ነው፤ የሚያሳጣኝ የለም።',
      },
      3: {
        'reference': 'ፊልጵስዩስ 4:13',
        'text': 'ኃይል በሚሰጠኝ በክርስቶስ ሁሉን እችላለሁ።',
      },
      // Add more verses here
    },
    'en': {
      1: {
        'reference': 'John 3:16',
        'text':
            'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      },
      2: {
        'reference': 'Psalm 23:1',
        'text': 'The Lord is my shepherd, I lack nothing.',
      },
      3: {
        'reference': 'Philippians 4:13',
        'text': 'I can do all this through him who gives me strength.',
      },
      // Add more verses here
    },
  };

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  double get fontSize => _fontSize;

  // Get verse text based on current language
  String getVerseText(int verseId) {
    return versesTranslations[_language]?[verseId]?['text'] ??
        versesTranslations['am']![verseId]!['text']!;
  }

  // Get verse reference based on current language
  String getVerseReference(int verseId) {
    return versesTranslations[_language]?[verseId]?['reference'] ??
        versesTranslations['am']![verseId]!['reference']!;
  }

  // Get topic name based on current language
  String getTopicName(String topicId) {
    return translations[_language]?[topicId] ?? translations['am']![topicId]!;
  }

  // Get topic description based on current language
  String getTopicDescription(String topicId) {
    return translations[_language]?['${topicId}_desc'] ??
        translations['am']!['${topicId}_desc']!;
  }

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
    _language = prefs.getString(_languageKey) ?? 'am';
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;
    notifyListeners();
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
}
