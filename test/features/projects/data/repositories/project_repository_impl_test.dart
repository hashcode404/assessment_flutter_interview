import 'package:assessment_flutter_interview/features/projects/data/data_sources/project_local_data_source.dart';
import 'package:assessment_flutter_interview/features/projects/data/data_sources/project_remote_data_source.dart';
import 'package:assessment_flutter_interview/features/projects/data/repositories/project_repository_impl.dart';
import 'package:assessment_flutter_interview/features/projects/domain/project_data_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProjectRemoteDataSource extends Mock
    implements ProjectRemoteDataSource {}

class MockProjectLocalDataSource extends Mock
    implements ProjectLocalDataSource {}

class FakeProjectDataModel extends Fake implements ProjectDataModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProjectDataModel());
  });

  late ProjectRepositoryImpl repository;
  late MockProjectRemoteDataSource mockRemoteDataSource;
  late MockProjectLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockProjectRemoteDataSource();
    mockLocalDataSource = MockProjectLocalDataSource();
    repository = ProjectRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tProjectModel = ProjectDataModel(
    id: '1',
    name: 'Test Project',
    description: 'A description',
    createdAt: DateTime.now(),
  );
  final tProjectList = [tProjectModel];

  group('getProjects', () {
    test(
        'should return remote data when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getProjects())
          .thenAnswer((_) async => tProjectList);
      when(() => mockLocalDataSource.cacheProjects(any()))
          .thenAnswer((_) async {});
      // act
      final result = await repository.getProjects();
      // assert
      verify(() => mockRemoteDataSource.getProjects());
      verify(() => mockLocalDataSource.cacheProjects(tProjectList));
      expect(result, equals(tProjectList));
    });

    test(
        'should return locally cached data when remote data source returns empty list',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getProjects())
          .thenAnswer((_) async => []);
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => tProjectList);
      // act
      final result = await repository.getProjects();
      // assert
      verify(() => mockRemoteDataSource.getProjects());
      verify(() => mockLocalDataSource.getCachedProjects());
      expect(result, equals(tProjectList));
    });

    test(
        'should return locally cached data when the call to remote data source is unsuccessful (throws Exception)',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getProjects()).thenThrow(Exception());
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => tProjectList);
      // act
      final result = await repository.getProjects();
      // assert
      verify(() => mockRemoteDataSource.getProjects());
      verify(() => mockLocalDataSource.getCachedProjects());
      expect(result, equals(tProjectList));
    });
  });

  group('addProject', () {
    test('should pass project to remote and update local cache', () async {
      // arrange
      when(() => mockRemoteDataSource.addProject(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => []);
      when(() => mockLocalDataSource.cacheProjects(any()))
          .thenAnswer((_) async {});
      // act
      await repository.addProject(tProjectModel);
      // assert
      verify(() => mockRemoteDataSource.addProject(tProjectModel));
      verify(() => mockLocalDataSource.cacheProjects([tProjectModel]));
    });

    test('should still update local cache if remote fails', () async {
      // arrange
      when(() => mockRemoteDataSource.addProject(any())).thenThrow(Exception());
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => []);
      when(() => mockLocalDataSource.cacheProjects(any()))
          .thenAnswer((_) async {});
      // act
      await repository.addProject(tProjectModel);
      // assert
      verify(() => mockRemoteDataSource.addProject(tProjectModel));
      verify(() => mockLocalDataSource.cacheProjects([tProjectModel]));
    });
  });

  group('updateProject', () {
    test('should pass update to remote and modify local cache correctly',
        () async {
      // arrange
      final updatedProject = tProjectModel.copyWith(name: 'New Name');
      when(() => mockRemoteDataSource.updateProject(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => [tProjectModel]); // contains original
      when(() => mockLocalDataSource.cacheProjects(any()))
          .thenAnswer((_) async {});

      // act
      await repository.updateProject(updatedProject);

      // assert
      verify(() => mockRemoteDataSource.updateProject(updatedProject));
      verify(() => mockLocalDataSource.cacheProjects([updatedProject]));
    });
  });

  group('deleteProject', () {
    test('should pass delete to remote and remove from local cache', () async {
      // arrange
      when(() => mockRemoteDataSource.deleteProject(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.getCachedProjects())
          .thenAnswer((_) async => [tProjectModel]);
      when(() => mockLocalDataSource.cacheProjects(any()))
          .thenAnswer((_) async {});

      // act
      await repository.deleteProject(tProjectModel.id);

      // assert
      verify(() => mockRemoteDataSource.deleteProject(tProjectModel.id));
      verify(() => mockLocalDataSource.cacheProjects([]));
    });
  });
}
