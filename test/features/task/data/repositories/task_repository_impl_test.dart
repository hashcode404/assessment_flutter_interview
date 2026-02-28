import 'package:assessment_flutter_interview/core/constants/enums.dart';
import 'package:assessment_flutter_interview/features/task/data/data_sources/task_local_data_source.dart';
import 'package:assessment_flutter_interview/features/task/data/data_sources/task_remote_data_source.dart';
import 'package:assessment_flutter_interview/features/task/data/repositories/task_repository_impl.dart';
import 'package:assessment_flutter_interview/features/task/domain/task_data_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

class FakeTaskDataModel extends Fake implements TaskDataModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTaskDataModel());
  });

  late TaskRepositoryImpl repository;
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockTaskLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockLocalDataSource = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tTaskModel = TaskDataModel(
    id: '1',
    title: 'Test Task',
    description: 'A test task',
    projectId: 'mock_project_id',
    stage: TaskType.todo,
  );
  final tTaskList = [tTaskModel];

  group('getTasks', () {
    test(
        'should return remote mapped tasks when call to remote data source handles efficiently',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getTasks())
          .thenAnswer((_) async => tTaskList);
      when(() => mockLocalDataSource.cacheTasks(any()))
          .thenAnswer((_) async {});
      // act
      final result = await repository.getTasks();
      // assert
      verify(() => mockRemoteDataSource.getTasks());
      verify(() => mockLocalDataSource.cacheTasks(tTaskList));
      expect(result, equals(tTaskList));
    });

    test(
        'should fetch from cached when remote data source returns completely empty list as fallback',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getTasks()).thenAnswer((_) async => []);
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => tTaskList);
      // act
      final result = await repository.getTasks();
      // assert
      verify(() => mockRemoteDataSource.getTasks());
      verify(() => mockLocalDataSource.getCachedTasks());
      expect(result, equals(tTaskList));
    });

    test('should fetch and provide local cache instances on remote Exceptions',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getTasks()).thenThrow(Exception());
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => tTaskList);
      // act
      final result = await repository.getTasks();
      // assert
      verify(() => mockRemoteDataSource.getTasks());
      verify(() => mockLocalDataSource.getCachedTasks());
      expect(result, equals(tTaskList));
    });
  });

  group('addTask', () {
    test('should invoke remote and local creation', () async {
      // arrange
      when(() => mockRemoteDataSource.addTask(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => []);
      when(() => mockLocalDataSource.cacheTasks(any()))
          .thenAnswer((_) async {});
      // act
      await repository.addTask(tTaskModel);
      // assert
      verify(() => mockRemoteDataSource.addTask(tTaskModel));
      verify(() => mockLocalDataSource.cacheTasks([tTaskModel]));
    });

    test('should persist seamlessly into cache even if network call dies',
        () async {
      // arrange
      when(() => mockRemoteDataSource.addTask(any())).thenThrow(Exception());
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => []);
      when(() => mockLocalDataSource.cacheTasks(any()))
          .thenAnswer((_) async {});
      // act
      await repository.addTask(tTaskModel);
      // assert
      verify(() => mockRemoteDataSource.addTask(tTaskModel));
      verify(() => mockLocalDataSource.cacheTasks([tTaskModel]));
    });
  });

  group('updateTask', () {
    test('should properly update existing task and submit changes everywhere',
        () async {
      // arrange
      final updatedTask = TaskDataModel(
          id: '1',
          title: 'Test',
          description: 'Desc',
          projectId: 'mock_project_id',
          stage: TaskType.inProgress);
      when(() => mockRemoteDataSource.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [tTaskModel]);
      when(() => mockLocalDataSource.cacheTasks(any()))
          .thenAnswer((_) async {});
      // act
      await repository.updateTask(updatedTask);
      // assert
      verify(() => mockRemoteDataSource.updateTask(updatedTask));
      verify(() => mockLocalDataSource.cacheTasks([updatedTask]));
    });
  });
}
