import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../main_page.dart';
import '../../settings/providers/settings_provider.dart';
// import '../../../providers/app_settings.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'እንኳን ደህና መጡ',
      'title_en': 'Welcome',
      'subtitle': 'የመጽሐፍ ቅዱስ ጥቅሶችን በቀላሉ ያስታውሱ',
      'subtitle_en': 'Remember Bible verses easily',
      'icon': Icons.book,
    },
    {
      'title': 'ጥቅሶችን ይማሩ',
      'title_en': 'Learn Verses',
      'subtitle': 'በየቀኑ አዳዲስ ጥቅሶችን ይለማመዱ',
      'subtitle_en': 'Practice new verses daily',
      'icon': Icons.school,
    },
    {
      'title': 'ይለማመዱ',
      'title_en': 'Practice',
      'subtitle': 'በተለያዩ መንገዶች እያገናዘቡ ይማሩ',
      'subtitle_en': 'Learn through various methods',
      'icon': Icons.psychology,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final isAmharic = settings.language == 'am';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      title: isAmharic
                          ? _pages[index]['title']!
                          : _pages[index]['title_en']!,
                      subtitle: isAmharic
                          ? _pages[index]['subtitle']!
                          : _pages[index]['subtitle_en']!,
                      icon: _pages[index]['icon']!,
                      theme: theme,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    TextButton(
                      onPressed: () => _onDone(context),
                      child: Text(
                        isAmharic ? 'እለፍ' : 'Skip',
                        style: (theme.textTheme.bodyLarge ??
                                const TextStyle(fontSize: 16))
                            .copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    // Dots indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    // Next/Done button
                    TextButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _onDone(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? (isAmharic ? 'ጀምር' : 'Start')
                            : (isAmharic ? 'ቀጥል' : 'Next'),
                        style: (theme.textTheme.bodyLarge ??
                                const TextStyle(fontSize: 16))
                            .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/playstore.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: (theme.textTheme.headlineMedium ??
                    const TextStyle(fontSize: 28))
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: (theme.textTheme.titleLarge ?? const TextStyle(fontSize: 18))
                .copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainPage()),
    );
  }
}


