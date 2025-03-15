import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/verses/screens/Dashboard.dart';
import 'features/practice/screens/practice_overview_screen.dart';
import 'features/verses/screens/explore_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/profile/screens/profile_screen.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ExploreScreen(),
    const PracticeOverviewScreen(),
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!; // Change 'en' to 'am'

    return Scaffold(
      body: _pages[settings.currentTab],
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
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: settings.currentTab,
            onTap: (index) => settings.navigateToTab(index),
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard, size: 24),
                label: settings.language == 'am' ? 'ዋና ገጽ' : 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore, size: 24),
                label: settings.language == 'am' ? 'አስስ' : 'Explore',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.school, size: 24),
                label: settings.language == 'am' ? 'ልምምድ' : 'Practice',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings, size: 24),
                label: settings.language == 'am' ? 'ቅንብሮች' : 'Settings',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person, size: 24),
                label: settings.language == 'am' ? 'መገለጫ' : 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
