class Verse {
  final int id;
  final String reference;
  final String referenceTranslation;
  final String verseText;
  final String translation;
  int progress;

  Verse({
    required this.id,
    required this.reference,
    required this.referenceTranslation,
    required this.verseText,
    required this.translation,
    this.progress = 0,
  });
}
