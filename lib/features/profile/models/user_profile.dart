class UserProfile {
  String name;
  String email;
  String imageUrl;
  int totalPracticeDays;
  DateTime lastPracticeDate;
  List<int> completedVerses;
  List<Achievement> achievements;
  int level;
  double experiencePoints;

  UserProfile({
    this.name = '',
    this.email = '',
    this.imageUrl = '',
    this.totalPracticeDays = 0,
    this.level = 1,
    this.experiencePoints = 0,
    DateTime? lastPracticeDate,
    List<int>? completedVerses,
    List<Achievement>? achievements,
  })  : lastPracticeDate = lastPracticeDate ?? DateTime.now(),
        completedVerses = completedVerses ?? [],
        achievements = achievements ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'imageUrl': imageUrl,
        'totalPracticeDays': totalPracticeDays,
        'lastPracticeDate': lastPracticeDate.toIso8601String(),
        'completedVerses': completedVerses.map((id) => id.toString()).toList(),
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'level': level,
        'experiencePoints': experiencePoints,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      totalPracticeDays: json['totalPracticeDays'] ?? 0,
      level: json['level'] ?? 1,
      experiencePoints: (json['experiencePoints'] ?? 0.0).toDouble(),
      lastPracticeDate: json['lastPracticeDate'] != null
          ? DateTime.parse(json['lastPracticeDate'])
          : DateTime.now(),
      completedVerses: (json['completedVerses'] as List?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          [],
      achievements: (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
    );
  }

  // Calculate required XP for next level
  double getRequiredXPForNextLevel() {
    return 1000.0 * level; // Adjust this formula as needed
  }

  // Calculate progress to next level (0.0 to 1.0)
  double getLevelProgress() {
    double requiredXP = getRequiredXPForNextLevel();
    double progress = experiencePoints / requiredXP;
    return progress.clamp(0.0, 1.0);
  }

  // Get level title based on current level
  String getLevelTitle() {
    if (level < 5) return 'beginner';
    if (level < 10) return 'intermediate';
    if (level < 15) return 'advanced';
    return 'master';
  }
}

class Achievement {
  final String title;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.title,
    required this.description,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isUnlocked': isUnlocked,
        'unlockedDate': unlockedDate?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        title: json['title'],
        description: json['description'],
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedDate: json['unlockedDate'] != null
            ? DateTime.parse(json['unlockedDate'])
            : null,
      );
}
