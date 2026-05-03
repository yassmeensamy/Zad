import 'dart:convert';

class ChoiceModel {
  const ChoiceModel({required this.index, required this.text});

  /// Server-assigned position of this choice within the question.
  final int index;
  final String text;

  factory ChoiceModel.fromMap(Map<String, dynamic> map) => ChoiceModel(
        index: (map['index'] as num).toInt(),
        text: (map['text'] ?? '') as String,
      );

  factory ChoiceModel.fromJson(String source) =>
      ChoiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {'index': index, 'text': text};

  String toJson() => json.encode(toMap());

  ChoiceModel copyWith({int? index, String? text}) =>
      ChoiceModel(index: index ?? this.index, text: text ?? this.text);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChoiceModel && other.index == index && other.text == text;
  }

  @override
  int get hashCode => Object.hash(index, text);

  @override
  String toString() => 'ChoiceModel(index: $index, text: $text)';
}
