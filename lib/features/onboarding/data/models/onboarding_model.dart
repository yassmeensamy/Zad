import 'dart:convert';

class OnboardingModel {
  final int pk;
  final String text;
  final String subText;
  final String image;

  const OnboardingModel({
    required this.pk,
    required this.text,
    required this.subText,
    required this.image,
  });

  OnboardingModel copyWith({
    int? pk,
    String? text,
    String? subText,
    String? image,
  }) => OnboardingModel(
    pk: pk ?? this.pk,
    text: text ?? this.text,
    subText: subText ?? this.subText,
    image: image ?? this.image,
  );

  Map<String, dynamic> toMap() => {
    'pk': pk,
    'text': text,
    'subText': subText,
    'image': image,
  };

  factory OnboardingModel.fromMap(Map<String, dynamic> map) => OnboardingModel(
    pk: map['pk'] as int? ?? 0,
    text: map['text'] as String? ?? '',
    subText: map['subText'] as String? ?? '',
    image: map['image'] as String? ?? '',
  );

  String toJson() => json.encode(toMap());

  factory OnboardingModel.fromJson(String source) =>
      OnboardingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingModel &&
          other.pk == pk &&
          other.text == text &&
          other.subText == subText &&
          other.image == image;

  @override
  int get hashCode => Object.hash(pk, text, subText, image);
}
