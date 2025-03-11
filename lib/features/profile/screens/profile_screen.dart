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
  int _totalPracticeDays = 0;
  double _averageScore = 0.0;
  late UserProfile _userProfile;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late AnimationController _levelProgressController;
  Map<int, double> _verseProgress = {};
  List<int> _completedVerseIds = [];

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
    final prefs = await SharedPreferences.getInstance();
    _progressService = ProgressService(prefs);
    _dashboardService = DashboardService(prefs);

    // Load user profile
    final userProfileJson = prefs.getString('user_profile');
    if (userProfileJson != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(userProfileJson));
    } else {
      _userProfile = UserProfile();
    }
    _nameController.text = _userProfile.name;
    _emailController.text = _userProfile.email;

    final verseIds = await _dashboardService.getDashboardVerses();
    int completed = 0;
    double totalScore = 0.0;
    Map<int, double> progress = {};
    List<int> completedIds = [];

    for (var id in verseIds) {
      final verseProgress = await _progressService.getVerseProgress(id);
      progress[id] = verseProgress;
      if (verseProgress >= 0.8) {
        completed++;
        completedIds.add(id);
      }
      totalScore += verseProgress;
    }

    final practiceDays = await _progressService.getPracticeDays();

    if (mounted) {
      setState(() {
        _completedVerses = completed;
        _totalPracticeDays = practiceDays;
        _averageScore =
            verseIds.isNotEmpty ? (totalScore / verseIds.length) * 100 : 0.0;
        _verseProgress = progress;
        _completedVerseIds = completedIds;
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
    final settings = Provider.of<AppSettings>(context, listen: false);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

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
    final settings = Provider.of<AppSettings>(context);
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
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

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
    final settings = Provider.of<AppSettings>(context);
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
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
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

    if (_completedVerseIds.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              translations['no_completed_verses'] ?? 'No verses completed yet',
              style: TextStyle(
                fontSize: settings.fontSize,
                color: settings.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations['mastered_verses'] ?? 'Mastered Verses',
              style: TextStyle(
                fontSize: settings.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: settings.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_completedVerseIds.length, (index) {
              final verseId = _completedVerseIds[index];
              final progress = _verseProgress[verseId] ?? 0.0;
              final reference = settings.getVerseReference(verseId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reference,
                          style: TextStyle(
                            fontSize: settings.fontSize,
                            color: settings.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: settings.fontSize - 2,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: settings.isDarkMode
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final translations = AppSettings.translations[settings.language] ??
        AppSettings.translations['am']!;

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
