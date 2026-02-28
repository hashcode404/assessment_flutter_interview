import 'package:assessment_flutter_interview/core/constants/enums.dart';
import 'package:hive/hive.dart';

part 'task_data_model.g.dart';

@HiveType(typeId: 1)
class TaskDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  TaskType stage;
  @HiveField(4)
  final String projectId;

  TaskDataModel({
    required this.id,
    required this.title,
    required this.description,
    required this.stage,
    required this.projectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'stage': stage
          .index, // Hive typically handles enums better by index or string, let's stick to name for JSON
    };
  }

  factory TaskDataModel.fromJson(Map<String, dynamic> json) {
    return TaskDataModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      projectId: (json['projectId'] ?? '').toString(),
      stage: json['stage'] is int
          ? TaskType.values[json['stage'] as int]
          : TaskType.values.firstWhere(
              (e) => e.name == json['stage'],
              orElse: () => TaskType.todo,
            ),
    );
  }
}
