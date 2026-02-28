import 'package:hive/hive.dart';

part 'project_data_model.g.dart';

@HiveType(typeId: 0)
class ProjectDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime createdAt;

  ProjectDataModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  ProjectDataModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectDataModel.fromJson(Map<String, dynamic> json) {
    return ProjectDataModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: json['createdAt'] is String
          ? (DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now())
          : (json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.now()),
    );
  }
}
