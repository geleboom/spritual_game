import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../verses/models/verse.dart';
import '../../progress/services/progress_service.dart';
import '../../verses/services/dashboard_service.dart';
import '../../settings/providers/settings_provider.dart';
import 'practice_style_screen.dart';

class PracticeOverviewScreen extends StatefulWidget {
  const PracticeOverviewScreen({super.key});

  @override
  State<PracticeOverviewScreen> createState() => _PracticeOverviewScreenState();
}

class _PracticeOverviewScreenState extends State<PracticeOverviewScreen> {
  late ProgressService _progressService;
  late DashboardService _dashboardService;
  List<Verse> _dashboardVerses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _progressService = ProgressService(prefs);
      _dashboardService = DashboardService(prefs);
      await _loadDashboardVerses();
    } catch (e) {
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final translations = SettingsProvider.translations[settings.language] ??
            SettingsProvider.translations['am']!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${translations['error']}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDashboardVerses() async {
    try {
      final verses = await _dashboardService.getDashboardVerses();

      if (mounted) {
        setState(() {
          _dashboardVerses = verses;
        });
      }

      await _loadProgress();
    } catch (e) {
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final translations = SettingsProvider.translations[settings.language] ??
            SettingsProvider.translations['am']!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${translations['error_loading_verses']}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadProgress() async {
    for (var verse in _dashboardVerses) {
      try {
        final readProgress =
            await _progressService.getVerseProgress(verse.id, mode: 'read') ??
                0.0;
        final blankProgress =
            await _progressService.getVerseProgress(verse.id, mode: 'blank') ??
                0.0;
        final typeProgress =
            await _progressService.getVerseProgress(verse.id, mode: 'type') ??
                0.0;

        // Calculate average progress and clamp between 0 and 100
        final averageProgress =
            ((readProgress + blankProgress + typeProgress) / 3)
                .clamp(0.0, 100.0);

        if (mounted) {
          setState(() {
            verse.progress = averageProgress.round();
          });
        }
      } catch (e) {
        print('Error loading progress for verse ${verse.id}: $e');
      }
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
              translations['no_verses_in_dashboard'] ??
                  (settings.language == 'am'
                      ? 'ዳሽቦርድ ውስጥ ጥቅሶች የሉም'
                      : 'No verses in dashboard'),
              style: TextStyle(
                fontSize: settings.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: settings.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              translations['add_verses_dashboard_instruction'] ??
                  (settings.language == 'am'
                      ? 'ጥቅሶችን ለልምምድ የመጀመር አስቀድሞ ከአስስ ገጽ ዳሽቦርድ ውስጥ ያክሉ'
                      : 'To practice verses, first add them to your dashboard from the Explore page'),
              style: TextStyle(
                fontSize: settings.fontSize - 2,
                color: settings.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (context.mounted) {
                  Provider.of<SettingsProvider>(context, listen: false)
                      .navigateToTab(1);
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                translations['go_to_explore'] ??
                    (settings.language == 'am'
                        ? 'አስስ ገጽ ይሂዱ'
                        : 'Go to Explore'),
                style: TextStyle(fontSize: settings.fontSize),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(
      SettingsProvider settings, Map<String, String> translations) {
    if (_dashboardVerses.isEmpty) return const SizedBox.shrink();

    final totalProgress = _dashboardVerses.fold<double>(
          0,
          (sum, verse) => sum + (verse.progress.clamp(0, 100) / 100),
        ) /
        _dashboardVerses.length;

    final completedVerses =
        _dashboardVerses.where((v) => v.progress >= 100).length;

    return Card(
      margin: const EdgeInsets.all(16),
      color: settings.isDarkMode ? Colors.black45 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations['practice_summary'] ??
                          (settings.language == 'am'
                              ? 'የልምምድ ማጠቃለያ'
                              : 'Practice Summary'),
                      style: TextStyle(
                        fontSize: settings.fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color:
                            settings.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translations['total_verses'] ??
                          (settings.language == 'am'
                              ? 'ጠቅላላ ጥቅሶች'
                              : 'Total Verses'),
                      style: TextStyle(
                        fontSize: settings.fontSize - 2,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                Text(
                  _dashboardVerses.length.toString(),
                  style: TextStyle(
                    fontSize: settings.fontSize + 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations['completed_verses'] ??
                          (settings.language == 'am'
                              ? 'የተጠናቀቁ ጥቅሶች'
                              : 'Completed Verses'),
                      style: TextStyle(
                        fontSize: settings.fontSize - 2,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translations['overall_progress'] ??
                          (settings.language == 'am'
                              ? 'አጠቃላይ እድገት'
                              : 'Overall Progress'),
                      style: TextStyle(
                        fontSize: settings.fontSize - 2,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      completedVerses.toString(),
                      style: TextStyle(
                        fontSize: settings.fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${(totalProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: settings.fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalProgress,
                backgroundColor: settings.isDarkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 8,
              ),
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
        title: Text(translations['practice'] ?? 'Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _initServices();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    translations['loading'] ?? 'Loading...',
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      color:
                          settings.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : Container(
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
                  ? _buildEmptyState(settings, translations)
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildProgressSummary(settings, translations),
                        const SizedBox(height: 16),
                        ...List.generate(_dashboardVerses.length, (index) {
                          final verse = _dashboardVerses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: settings.isDarkMode
                                ? Colors.black45
                                : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.language == 'am'
                                        ? verse.reference
                                        : verse.referenceTranslation,
                                    style: TextStyle(
                                      fontSize: settings.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: settings.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    settings.language == 'am'
                                        ? verse.verseText
                                        : verse.translation,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: settings.fontSize - 2,
                                      color: settings.isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${verse.progress}% ${translations['completed'] ?? 'completed'}',
                                        style: TextStyle(
                                          fontSize: settings.fontSize - 2,
                                          color: settings.isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final shouldRefresh =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PracticeStyleScreen(
                                                      verse: verse),
                                            ),
                                          );

                                          if (shouldRefresh == true &&
                                              mounted) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            await _initServices();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: Text(
                                          translations['practice'] ??
                                              'Practice',
                                          style: TextStyle(
                                            fontSize: settings.fontSize - 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
    );
  }
}
