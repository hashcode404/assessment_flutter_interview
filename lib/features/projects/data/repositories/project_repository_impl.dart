import 'package:flutter/foundation.dart';
import '../../domain/project_data_model.dart';
import '../../domain/project_repository.dart';
import '../data_sources/project_local_data_source.dart';
import '../data_sources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ProjectDataModel>> getProjects() async {
    try {
      final remoteProjects = await remoteDataSource.getProjects();
      // If remote succeeds, update local cache
      if (remoteProjects.isNotEmpty) {
        await localDataSource.cacheProjects(remoteProjects);
        return remoteProjects;
      } else {
        // Just return local if remote comes back empty (for mock fallback)
        final localProjects = await localDataSource.getCachedProjects();
        return localProjects;
      }
    } catch (e) {
      debugPrint('Firebase getProjects Error: $e');
      // Return cached list if offline or error
      final localProjects = await localDataSource.getCachedProjects();
      return localProjects;
    }
  }

  @override
  Future<void> addProject(ProjectDataModel project) async {
    try {
      await remoteDataSource.addProject(project);
    } catch (e) {
      debugPrint('Firebase addProject Error: $e');
    }
    final projects = await localDataSource.getCachedProjects();
    projects.add(project);
    await localDataSource.cacheProjects(projects);
  }

  @override
  Future<void> updateProject(ProjectDataModel project) async {
    try {
      await remoteDataSource.updateProject(project);
    } catch (e) {
      debugPrint('Firebase updateProject Error: $e');
    }
    final projects = await localDataSource.getCachedProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await localDataSource.cacheProjects(projects);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await remoteDataSource.deleteProject(id);
    } catch (e) {
      debugPrint('Firebase deleteProject Error: $e');
    }
    final projects = await localDataSource.getCachedProjects();
    projects.removeWhere((p) => p.id == id);
    await localDataSource.cacheProjects(projects);
  }
}
