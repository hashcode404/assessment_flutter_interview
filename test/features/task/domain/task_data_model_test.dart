import 'package:assessment_flutter_interview/core/constants/enums.dart';
import 'package:assessment_flutter_interview/features/task/domain/task_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskDataModel', () {
    final tTaskModel = TaskDataModel(
      id: '1',
      title: 'Task 1',
      description: 'A test task',
      projectId: 'mock_project_id',
      stage: TaskType.todo,
    );

    test('toJson returns a valid map with int representation of enum', () {
      final result = tTaskModel.toJson();

      final expectedMap = {
        'id': '1',
        'title': 'Task 1',
        'description': 'A test task',
        'projectId': 'mock_project_id',
        'stage': TaskType.todo.index,
      };

      expect(result, equals(expectedMap));
    });

    test('fromJson int stage returns a valid model', () {
      final map = {
        'id': '1',
        'title': 'Task 1',
        'description': 'A test task',
        'projectId': 'mock_project_id',
        'stage': TaskType.inProgress.index,
      };

      final result = TaskDataModel.fromJson(map);

      expect(result.id, '1');
      expect(result.title, 'Task 1');
      expect(result.description, 'A test task');
      expect(result.stage, TaskType.inProgress);
    });

    test('fromJson string stage returns a valid model', () {
      final map = {
        'id': '1',
        'title': 'Task 1',
        'description': 'A test task',
        'projectId': 'mock_project_id',
        'stage': TaskType.done.name,
      };

      final result = TaskDataModel.fromJson(map);

      expect(result.id, '1');
      expect(result.title, 'Task 1');
      expect(result.description, 'A test task');
      expect(result.stage, TaskType.done);
    });

    test('fromJson unknown string stage falls back to todo', () {
      final map = {
        'id': '1',
        'title': 'Task 1',
        'description': 'A test task',
        'projectId': 'mock_project_id',
        'stage': 'unknown_stage_string',
      };

      final result = TaskDataModel.fromJson(map);

      expect(result.stage, TaskType.todo);
    });
  });
}
