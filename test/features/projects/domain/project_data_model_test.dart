import 'package:assessment_flutter_interview/features/projects/domain/project_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectDataModel', () {
    final tDate = DateTime.parse('2023-01-01T00:00:00.000');
    final tProjectModel = ProjectDataModel(
      id: '1',
      name: 'Test Project',
      description: 'A description',
      createdAt: tDate,
    );

    test('copyWith creates a new instance with expected properties', () {
      final updatedProject = tProjectModel.copyWith(name: 'Updated Name');

      expect(updatedProject.id, tProjectModel.id);
      expect(updatedProject.name, 'Updated Name');
      expect(updatedProject.description, tProjectModel.description);
      expect(updatedProject.createdAt, tProjectModel.createdAt);
    });

    test('toJson returns a valid map', () {
      final result = tProjectModel.toJson();

      final expectedMap = {
        'id': '1',
        'name': 'Test Project',
        'description': 'A description',
        'createdAt': '2023-01-01T00:00:00.000',
      };

      expect(result, expectedMap);
    });

    test('fromJson string date returns a valid model', () {
      final map = {
        'id': '1',
        'name': 'Test Project',
        'description': 'A description',
        'createdAt': '2023-01-01T00:00:00.000',
      };

      final result = ProjectDataModel.fromJson(map);

      expect(result.id, tProjectModel.id);
      expect(result.name, tProjectModel.name);
      expect(result.description, tProjectModel.description);
      expect(result.createdAt, tProjectModel.createdAt);
    });

    test('fromJson DateTime object returns a valid model', () {
      final map = {
        'id': '1',
        'name': 'Test Project',
        'description': 'A description',
        'createdAt': tDate, // testing parsing directly from DateTime
      };

      final result = ProjectDataModel.fromJson(map);

      expect(result.id, tProjectModel.id);
      expect(result.name, tProjectModel.name);
      expect(result.description, tProjectModel.description);
      expect(result.createdAt, tProjectModel.createdAt);
    });
  });
}
