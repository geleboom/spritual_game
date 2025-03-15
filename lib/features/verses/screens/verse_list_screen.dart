import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';
import '../services/dashboard_service.dart';
import '../data/verses_data.dart';
import '../../settings/providers/settings_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';

class VerseListScreen extends StatefulWidget {
  const VerseListScreen({super.key});

  @override
  State<VerseListScreen> createState() => _VerseListScreenState();
}

class _VerseListScreenState extends State<VerseListScreen> {
  List<Verse> _dashboardVerses = [];
  late DashboardService _dashboardService;

  @override
  void initState() {
    super.initState();
    _initDashboardService();
  }

  Future<void> _initDashboardService() async {
    final prefs = await SharedPreferences.getInstance();
    _dashboardService = DashboardService(prefs);
    await _loadDashboardVerses();
  }

  Future<void> _loadDashboardVerses() async {
    final verseIds = await _dashboardService.getDashboardVerses();
    if (mounted) {
      setState(() {
        _dashboardVerses = verseIds.map((id) => versesData[id]!).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          translations['dashboard'] ?? 'ዳሽቦርድ',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black],
          ),
        ),
        child: _dashboardVerses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      translations['no_verse'] ?? 'ከአስስ ገጽ እስከ 5 ጥቅሶችን ይምረጡ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 100, bottom: 20),
                itemCount: _dashboardVerses.length,
                itemBuilder: (context, index) {
                  final verse = _dashboardVerses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    verse.reference,
                                    style: (Theme.of(context)
                                                .textTheme
                                                .titleLarge ??
                                            const TextStyle(fontSize: 24))
                                        .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await _dashboardService
                                        .removeFromDashboard(verse.id);
                                    await _loadDashboardVerses();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              settings.language == 'am'
                                  ? verse.verseText
                                  : verse.translation,
                              style: (Theme.of(context).textTheme.bodyLarge ??
                                      TextStyle(fontSize: settings.fontSize))
                                  .copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
