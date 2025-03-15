import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';
import '../services/dashboard_service.dart';
import '../../settings/providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final verses = await _dashboardService.getDashboardVerses();
    if (mounted) {
      setState(() {
        _dashboardVerses = verses;
      });
    }
  }

  Widget _buildEmptyState(
      SettingsProvider settings, Map<String, String> translations) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_add_outlined,
              size: 80,
              color: settings.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(height: 24),
            Text(
              translations['no_verses_in_dashboard'] ?? 'ምንም ጥቅሶች በዳሽቦርድ የሉም',
              style: TextStyle(
                fontSize: 18,
                color: settings.isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(translations['dashboard'] ?? 'ዳሽቦርድ'),
        actions: const [
          Icon(Icons.dashboard), // Added dashboard icon
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade900, Colors.blue.shade800],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/icons/playstore.png', // Changed from Icon(Icons.book)
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.language == 'am'
                                ? 'መንፈሳዊ እድገት'
                                : 'Spiritual Growth',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.language == 'am'
                                ? 'በየቀኑ በቃል ኪዳን ውስጥ ያድጉ'
                                : 'Grow in faith through daily verses',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        settings.language == 'am'
                            ? '"እግዚአብሔር ያለውን ያህል ለዓለም ወዶአልና አንድያ ልጁን ሰጠ፤ እርሱን የሚያምን ሁሉ የዘላለም ሕይወት እንዲኖረው እንጂ እንዳይጠፋ።"'
                            : '"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.language == 'am' ? 'ዮሐንስ 3:16' : 'John 3:16',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _dashboardVerses.isEmpty
                ? _buildEmptyState(settings,
                    translations) // Using the existing empty state widget
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dashboardVerses.length,
                    itemBuilder: (context, index) {
                      final verse = _dashboardVerses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            settings.language == 'en'
                                ? verse.referenceTranslation
                                : verse.reference,
                            style: TextStyle(
                              fontSize: settings.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            settings.language == 'en'
                                ? verse.translation
                                : verse.verseText,
                            style: TextStyle(fontSize: settings.fontSize),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () async {
                              await _dashboardService
                                  .removeFromDashboard(verse.id);
                              await _loadDashboardVerses();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(settings.language == 'am'
                                        ? 'ጥቅሱ ከዳሽቦርድ ተወግዷል'
                                        : 'Verse removed from dashboard'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
