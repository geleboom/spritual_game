import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../../progress/services/progress_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../../verses/services/dashboard_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late ProgressService _progressService;
  late DashboardService _dashboardService;
  bool _isLoading = true;
  int _completedVerses = 0;
  final int _totalPracticeDays = 0;
  double _averageScore = 0.0;
  late UserProfile _userProfile;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late AnimationController _levelProgressController;
  Map<int, double> _verseProgress = {};
  final List<int> _completedVerseIds = [];

  @override
  void initState() {
    super.initState();
    _levelProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _levelProgressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _progressService = ProgressService(prefs);
      _dashboardService = DashboardService(prefs);

      // Load user profile
      final userProfileJson = prefs.getString('user_profile');
      if (userProfileJson != null) {
        _userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));
        _completedVerses = _userProfile.completedVerses.length;
      }

      final verses = await _dashboardService.getDashboardVerses();
      print('Loaded ${verses.length} verses');

      // Calculate average score from verse progress
      double totalScore = 0.0;
      Map<int, double> progress = {};

      for (var verse in verses) {
        try {
          // Get progress for each mode
          final readProgress =
              await _progressService.getVerseProgress(verse.id, mode: 'read') ??
                  0.0;
          final blankProgress = await _progressService
                  .getVerseProgress(verse.id, mode: 'blank') ??
              0.0;
          final typeProgress =
              await _progressService.getVerseProgress(verse.id, mode: 'type') ??
                  0.0;

          // Calculate average progress for the verse
          final verseProgress =
              ((readProgress + blankProgress + typeProgress) / 3)
                  .clamp(0.0, 100.0);
          progress[verse.id] = verseProgress;
          totalScore += verseProgress;

          print('Verse ${verse.id} progress:');
          print('- Read: $readProgress');
          print('- Blank: $blankProgress');
          print('- Type: $typeProgress');
          print('- Average: $verseProgress');
        } catch (e) {
          print('Error calculating progress for verse ${verse.id}: $e');
          continue;
        }
      }

      // Calculate average score
      if (verses.isNotEmpty) {
        _averageScore = (totalScore / verses.length).clamp(0.0, 100.0);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _verseProgress = progress;
      });
    } catch (e) {
      print('Error loading profile: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userProfile.name = _nameController.text;
    _userProfile.email = _emailController.text;
    await prefs.setString('user_profile', jsonEncode(_userProfile.toJson()));
  }

  void _showEditDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: settings.isDarkMode ? Colors.black87 : Colors.white,
        title: Text(
          translations['edit_profile'] ?? 'መገለጫ ያስተካክሉ',
          style: TextStyle(
            color: settings.isDarkMode ? Colors.white : Colors.black87,
            fontSize: settings.fontSize + 2,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(
                  color: settings.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: settings.fontSize,
                ),
                decoration: InputDecoration(
                  labelText: translations['name'] ?? 'ስም',
                  labelStyle: TextStyle(
                    color:
                        settings.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          settings.isDarkMode ? Colors.white30 : Colors.black26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: TextStyle(
                  color: settings.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: settings.fontSize,
                ),
                decoration: InputDecoration(
                  labelText: translations['email'] ?? 'ኢሜይል',
                  labelStyle: TextStyle(
                    color:
                        settings.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          settings.isDarkMode ? Colors.white30 : Colors.black26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              translations['cancel'] ?? 'ሰርዝ',
              style: TextStyle(fontSize: settings.fontSize),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveProfile();
              if (mounted) {
                Navigator.pop(context);
                setState(() {}); // Refresh the UI
              }
            },
            child: Text(
              translations['save'] ?? 'አስቀምጥ',
              style: TextStyle(fontSize: settings.fontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {IconData? icon}) {
    final settings = Provider.of<SettingsProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: settings.fontSize,
                color: settings.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: settings.fontSize,
              fontWeight: FontWeight.bold,
              color: settings.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator() {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    final progress = _userProfile.getLevelProgress();
    _levelProgressController.value = progress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translations['level']} ${_userProfile.level}',
                      style: TextStyle(
                        fontSize: settings.fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color:
                            settings.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translations[
                              _userProfile.getLevelTitle().toLowerCase()] ??
                          _userProfile.getLevelTitle(),
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star,
                          color: Colors.amber, size: settings.fontSize + 4),
                      const SizedBox(width: 4),
                      Text(
                        _userProfile.experiencePoints.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' XP',
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: settings.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translations['level_progress'] ?? 'Level Progress',
                      style: TextStyle(
                        fontSize: settings.fontSize - 2,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: settings.fontSize - 2,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: settings.isDarkMode
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _levelProgressController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _levelProgressController.value,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.lightBlue],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_userProfile.experiencePoints.toStringAsFixed(0)} / ${_userProfile.getRequiredXPForNextLevel().toStringAsFixed(0)} XP',
                  style: TextStyle(
                    fontSize: settings.fontSize - 2,
                    color:
                        settings.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final settings = Provider.of<SettingsProvider>(context);
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent, // Changed from blue
                    child: Image.asset(
                      'assets/icons/playstore.png', // Changed from Icon(Icons.person)
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userProfile.name,
                    style: TextStyle(
                      fontSize: settings.fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: settings.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (_userProfile.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _userProfile.email,
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        color: settings.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedVerses() {
    final settings = Provider.of<SettingsProvider>(context);
    final translations = SettingsProvider.translations[settings.language] ??
        SettingsProvider.translations['am']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['completed_verses'] ?? 'Completed Verses',
              style: TextStyle(
                fontSize: settings.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: settings.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _completedVerses.toString(),
                  style: TextStyle(
                    fontSize: settings.fontSize + 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: settings.fontSize + 8,
                ),
              ],
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
        title: Text(translations['profile'] ?? 'መገለጫ'),
        backgroundColor: Colors.blue.shade400,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLevelIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          translations['statistics'] ?? 'ስታትስቲክስ',
                          style: TextStyle(
                            fontSize: settings.fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildStatItem(
                                  translations['completed_verses'] ??
                                      'የተጠናቀቁ ጥቅሶች',
                                  _completedVerses.toString(),
                                  icon: Icons.check_circle,
                                ),
                                _buildStatItem(
                                  translations['practice_days'] ?? 'የልምምድ ቀናት',
                                  _totalPracticeDays.toString(),
                                  icon: Icons.calendar_today,
                                ),
                                _buildStatItem(
                                  translations['average_score'] ?? 'አማካይ ውጤት',
                                  '${_averageScore.toStringAsFixed(1)}%',
                                  icon: Icons.star,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          translations['completed_references'] ??
                              'Completed Verses List',
                          style: TextStyle(
                            fontSize: settings.fontSize + 2,
                            fontWeight: FontWeight.bold,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCompletedVerses(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
