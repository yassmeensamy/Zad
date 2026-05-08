import 'dart:convert';

class HadithModel {
  const HadithModel({
    required this.id,
    required this.source,
    required this.arabic,
    required this.english,
    required this.narrator,
    required this.hadithNumber,
  });

  factory HadithModel.fromMap(Map<String, dynamic> map) => HadithModel(
    id: map['id'] as int,
    source: map['source'] as String,
    arabic: map['arabic'] as String,
    english: map['english'] as String,
    narrator: map['narrator'] as String,
    hadithNumber: map['hadithNumber'] as int,
  );

  factory HadithModel.fromJson(String source) =>
      HadithModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int id;

  /// Collection name, e.g. "Saḥīḥ al-Bukhārī".
  final String source;

  /// Original Arabic text of the hadith.
  final String arabic;

  /// English translation.
  final String english;

  /// Narrator name as displayed (transliterated).
  final String narrator;

  /// Position within the source collection.
  final int hadithNumber;

  HadithModel copyWith({
    int? id,
    String? source,
    String? arabic,
    String? english,
    String? narrator,
    int? hadithNumber,
  }) => HadithModel(
    id: id ?? this.id,
    source: source ?? this.source,
    arabic: arabic ?? this.arabic,
    english: english ?? this.english,
    narrator: narrator ?? this.narrator,
    hadithNumber: hadithNumber ?? this.hadithNumber,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'source': source,
    'arabic': arabic,
    'english': english,
    'narrator': narrator,
    'hadithNumber': hadithNumber,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HadithModel &&
        other.id == id &&
        other.source == source &&
        other.arabic == arabic &&
        other.english == english &&
        other.narrator == narrator &&
        other.hadithNumber == hadithNumber;
  }

  @override
  int get hashCode =>
      Object.hash(id, source, arabic, english, narrator, hadithNumber);
}
