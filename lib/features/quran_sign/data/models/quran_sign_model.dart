class QuranSignModel {
  const QuranSignModel({
    required this.id,
    required this.text,
    this.surahName,
    this.madaniNumber,
  });

  factory QuranSignModel.fromMap(Map<String, dynamic> map) => QuranSignModel(
    id: (map['id'] as num).toInt(),
    text: map['text'] as String,
    surahName: map['surahName'] as String?,
    madaniNumber: (map['madaniNumber'] as num?)?.toInt(),
  );

  final int id;
  final String text;
  final String? surahName;
  final int? madaniNumber;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuranSignModel &&
        other.id == id &&
        other.text == text &&
        other.surahName == surahName &&
        other.madaniNumber == madaniNumber;
  }

  @override
  int get hashCode => Object.hash(id, text, surahName, madaniNumber);
}
