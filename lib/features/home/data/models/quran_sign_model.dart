import 'dart:convert';

/// A single "Quran sign of the day" entry, as returned by
/// `GET /api/quran-signs/random`.
class QuranSignModel {
  const QuranSignModel({
    required this.id,
    required this.text,
    required this.referenceNumber,
    this.createdAt,
  });

  factory QuranSignModel.fromMap(Map<String, dynamic> map) => QuranSignModel(
    id: map['id'] as int,
    text: map['text'] as String,
    referenceNumber: map['referenceNumber'] as int,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.parse(map['createdAt'] as String).toLocal(),
  );

  factory QuranSignModel.fromJson(String source) =>
      QuranSignModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int id;

  /// The sign's text, displayed as the card body.
  final String text;

  /// Reference number shown in the card footer.
  final int referenceNumber;

  /// When the sign was created (server time, kept for completeness).
  final DateTime? createdAt;

  QuranSignModel copyWith({
    int? id,
    String? text,
    int? referenceNumber,
    DateTime? createdAt,
  }) => QuranSignModel(
    id: id ?? this.id,
    text: text ?? this.text,
    referenceNumber: referenceNumber ?? this.referenceNumber,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'referenceNumber': referenceNumber,
    'createdAt': createdAt?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuranSignModel &&
        other.id == id &&
        other.text == text &&
        other.referenceNumber == referenceNumber &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, text, referenceNumber, createdAt);
}
