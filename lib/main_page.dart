import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/verses/screens/verse_list_screen.dart';
import 'features/practice/screens/practice_overview_screen.dart';
import 'features/verses/screens/explore_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreScreen(),
    const VerseListScreen(),
    const PracticeOverviewScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore),
              label: translations['explore'] ?? 'አስስ',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: translations['dashboard'] ?? 'ጥቅሶች',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school),
              label: translations['practice'] ?? 'ልምምድ',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: translations['settings'] ?? 'ቅንብሮች',
            ),
          ],
        ),
      ),
    );
  }
}
