import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse_category.dart';
import '../services/dashboard_service.dart';
import '../data/verses_data.dart';
import '../../settings/providers/settings_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late DashboardService _dashboardService;
  final Map<int, bool> _verseInDashboard = {};
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _initDashboardService();
  }

  Future<void> _initDashboardService() async {
    final prefs = await SharedPreferences.getInstance();
    _dashboardService = DashboardService(prefs);
    await _loadDashboardStatus();
  }

  Future<void> _loadDashboardStatus() async {
    if (!mounted) return;

    final currentCategory = VerseCategory.categories[_selectedCategoryIndex];
    setState(() {
      _verseInDashboard.clear(); // Clear previous status
    });

    for (var verseId in currentCategory.verseIds) {
      if (!mounted) return;
      final isInDashboard = await _dashboardService.isInDashboard(verseId);
      setState(() {
        _verseInDashboard[verseId] = isInDashboard;
      });
    }
  }

  Future<void> _toggleDashboard(int verseId) async {
    try {
      final isInDashboard = _verseInDashboard[verseId] ?? false;
      final settings = Provider.of<AppSettings>(context, listen: false);
      final translations = AppSettings.translations[settings.language] ??
          AppSettings.translations['am']!;

      if (isInDashboard) {
        final success = await _dashboardService.removeFromDashboard(verseId);
        if (mounted && success) {
          setState(() {
            _verseInDashboard[verseId] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations['verseRemoved'] ?? 'ጥቅሱ ከዳሽቦርድ ተወግዷል'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Check if dashboard is full
        final verseCount = await _dashboardService.getDashboardVerseCount();
        if (verseCount >= DashboardService.maxVerses) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  translations['dashboardFull'] ?? 'ዳሽቦርድ ሙሉ ነው (5 ጥቅሶች)',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        final success = await _dashboardService.addToDashboard(verseId);
        if (mounted && success) {
          setState(() {
            _verseInDashboard[verseId] = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translations['verseAdded'] ?? 'ጥቅሱ ወደ ዳሽቦርድ ተጨምሯል'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onCategoryChanged(int index) async {
    setState(() {
      _selectedCategoryIndex = index;
    });
    await _loadDashboardStatus();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(translations['explore'] ?? 'አስስ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                translations['topics'] ?? 'ርዕሶች',
                style: (theme.textTheme.titleLarge ??
                        const TextStyle(fontSize: 24))
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: VerseCategory.categories.length,
                itemBuilder: (context, index) {
                  final category = VerseCategory.categories[index];
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => _onCategoryChanged(index),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [Colors.blue.shade700, Colors.blue.shade900]
                              : [
                                  theme.cardColor,
                                  theme.cardColor.withOpacity(0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.icon.split(' ')[0],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            settings.language == 'am'
                                ? category.nameAm
                                : category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.language == 'am'
                        ? VerseCategory
                            .categories[_selectedCategoryIndex].nameAm
                        : VerseCategory.categories[_selectedCategoryIndex].name,
                    style: (theme.textTheme.titleMedium ??
                            const TextStyle(fontSize: 20))
                        .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.getTopicDescription(
                      VerseCategory.categories[_selectedCategoryIndex].id,
                    ),
                    style: (theme.textTheme.bodyMedium ??
                            const TextStyle(fontSize: 14))
                        .copyWith(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: VerseCategory
                  .categories[_selectedCategoryIndex].verseIds.length,
              itemBuilder: (context, index) {
                final verseId = VerseCategory
                    .categories[_selectedCategoryIndex].verseIds[index];
                final isInDashboard = _verseInDashboard[verseId] ?? false;
                final verse = versesData[verseId]!;

                return Card(
                  color: theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                settings.language == 'am'
                                    ? verse.reference
                                    : verse.referenceTranslation,
                                style: theme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isInDashboard
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: isInDashboard
                                    ? Colors.green
                                    : theme.iconTheme.color,
                              ),
                              onPressed: () => _toggleDashboard(verseId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settings.language == 'am'
                              ? verse.verseText
                              : verse.translation,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
