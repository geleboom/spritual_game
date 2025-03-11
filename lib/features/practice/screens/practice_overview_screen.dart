import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../verses/models/verse.dart';
import '../../verses/data/verses_data.dart';
import '../../progress/services/progress_service.dart';
import '../../verses/services/dashboard_service.dart';
import '../../settings/providers/settings_provider.dart';
import 'practice_screen.dart';

class PracticeOverviewScreen extends StatefulWidget {
  const PracticeOverviewScreen({super.key});

  @override
  State<PracticeOverviewScreen> createState() => _PracticeOverviewScreenState();
}

class _PracticeOverviewScreenState extends State<PracticeOverviewScreen> {
  late ProgressService _progressService;
  late DashboardService _dashboardService;
  List<Verse> _dashboardVerses = [];

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    _progressService = ProgressService(prefs);
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
    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    for (var verse in _dashboardVerses) {
      final progress = await _progressService.getVerseProgress(verse.id);
      if (mounted) {
        setState(() {
          verse.progress = (progress * 100).round();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(translations['practice'] ?? 'ልምምድ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: settings.isDarkMode
                ? [Colors.black87, Colors.black]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: _dashboardVerses.isEmpty
            ? Center(
                child: Text(
                  translations['no_verses_in_dashboard'] ??
                      'ምንም ጥቅሶች በዳሽቦርድ የሉም',
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    color: settings.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _dashboardVerses.length,
                itemBuilder: (context, index) {
                  final verse = _dashboardVerses[index];
                  return Card(
                    color: settings.isDarkMode ? Colors.black45 : Colors.white,
                    child: ListTile(
                      title: Text(
                        settings.getVerseReference(verse.id),
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: settings.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.getVerseText(verse.id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: settings.fontSize - 2,
                              color: settings.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: verse.progress / 100,
                            backgroundColor: settings.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${verse.progress}% ${translations['completed'] ?? 'ተጠናቅቋል'}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: settings.fontSize - 4,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticeScreen(verse: verse),
                          ),
                        );
                        _loadProgress(); // Reload progress after practice
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
