class VerseCategory {
  final String id;
  final String name;
  final String nameAm;
  final String icon;
  final List<int> verseIds;

  const VerseCategory({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.icon,
    required this.verseIds,
  });

  static const List<VerseCategory> categories = [
    VerseCategory(
      id: 'anger',
      name: 'Anger',
      nameAm: 'ቁጣ',
      icon: '😠 🤬 💢',
      verseIds: [1, 2, 3],
    ),
    VerseCategory(
      id: 'contentment',
      name: 'Contentment',
      nameAm: 'እርካታ',
      icon: '😌 ☮️ 🙏',
      verseIds: [4, 5, 6],
    ),
    VerseCategory(
      id: 'encouragement',
      name: 'Encouragement',
      nameAm: 'ማበረታታት',
      icon: '💪 🌟 ✨',
      verseIds: [7, 8, 9],
    ),
    VerseCategory(
      id: 'faith',
      name: 'Faith',
      nameAm: 'እምነት',
      icon: '✝️ 🙏 ⛪',
      verseIds: [10, 11, 12],
    ),
    VerseCategory(
      id: 'fear',
      name: 'Fear',
      nameAm: 'ፍርሃት',
      icon: '😨 😰 💭',
      verseIds: [13, 14, 15],
    ),
    VerseCategory(
      id: 'giving',
      name: 'Giving',
      nameAm: 'መስጠት',
      icon: '🎁 🤲 💝',
      verseIds: [16, 17, 18],
    ),
    VerseCategory(
      id: 'love',
      name: 'Love',
      nameAm: 'ፍቅር',
      icon: '❤️ 💖 🫂',
      verseIds: [19, 20, 21],
    ),
    VerseCategory(
      id: 'lust',
      name: 'Lust',
      nameAm: 'ምኞት',
      icon: '😈 💔 ⚠️',
      verseIds: [22, 23, 24],
    ),
    VerseCategory(
      id: 'pride',
      name: 'Pride',
      nameAm: 'ትዕቢት',
      icon: '👑 😤 💫',
      verseIds: [25, 26, 27],
    ),
    VerseCategory(
      id: 'others',
      name: 'Others',
      nameAm: 'ሌሎች',
      icon: '📚 📖 ✨',
      verseIds: [28, 29, 30],
    ),
  ];
}
