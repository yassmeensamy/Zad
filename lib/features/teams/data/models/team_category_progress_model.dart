import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_member_progress_model.dart';

class TeamCategoryProgressModel {
  const TeamCategoryProgressModel({
    required this.categoryId,
    required this.categoryName,
    required this.totalLevels,
    this.members = const [],
  });

  final int categoryId;
  final String categoryName;
  final int totalLevels;
  final List<TeamMemberProgressModel> members;

  factory TeamCategoryProgressModel.fromMap(Map<String, dynamic> map) =>
      TeamCategoryProgressModel(
        categoryId: (map['categoryId'] as num?)?.toInt() ?? 0,
        categoryName: map['categoryName'] as String? ?? '',
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
        members:
            (map['members'] as List<dynamic>?)
                ?.map(
                  (e) => TeamMemberProgressModel.fromMap(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
      );

  factory TeamCategoryProgressModel.fromJson(String source) =>
      TeamCategoryProgressModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'totalLevels': totalLevels,
    'members': members.map((e) => e.toMap()).toList(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamCategoryProgressModel &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.totalLevels == totalLevels &&
        listEquals(other.members, members);
  }

  @override
  int get hashCode => Object.hash(
    categoryId,
    categoryName,
    totalLevels,
    Object.hashAll(members),
  );

  @override
  String toString() =>
      'TeamCategoryProgressModel(categoryId: $categoryId, '
      'categoryName: $categoryName, totalLevels: $totalLevels)';
}
