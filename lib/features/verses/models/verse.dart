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

  // Convert Verse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'referenceTranslation': referenceTranslation,
      'verseText': verseText,
      'translation': translation,
    };
  }

  // Create Verse from JSON
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as int,
      reference: json['reference'] as String,
      referenceTranslation: json['referenceTranslation'] as String,
      verseText: json['verseText'] as String,
      translation: json['translation'] as String,
    );
  }
}
