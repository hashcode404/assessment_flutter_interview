import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/project_data_model.dart';
import 'domain/project_repository.dart';
import 'data/data_sources/project_local_data_source.dart';
import 'data/data_sources/project_remote_data_source.dart';
import 'data/repositories/project_repository_impl.dart';
import '../../core/providers/core_providers.dart';

final projectLocalDataSourceProvider = Provider<ProjectLocalDataSource>((ref) {
  return ProjectLocalDataSourceImpl();
});

final projectRemoteDataSourceProvider =
    Provider<ProjectRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ProjectRemoteDataSourceImpl(firestore: firestore);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    localDataSource: ref.watch(projectLocalDataSourceProvider),
    remoteDataSource: ref.watch(projectRemoteDataSourceProvider),
  );
});

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<ProjectDataModel>>(() {
  return ProjectsNotifier();
});

class ProjectsNotifier extends AsyncNotifier<List<ProjectDataModel>> {
  @override
  Future<List<ProjectDataModel>> build() async {
    final repository = ref.watch(projectRepositoryProvider);
    return await repository.getProjects();
  }

  Future<void> addProject(String name, String description) async {
    if (state is AsyncLoading) return;

    final project = ProjectDataModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    // Optimistic update
    final previousState = state;
    if (previousState.hasValue) {
      state = AsyncValue.data([...previousState.value!, project]);
    }

    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.addProject(project);
    } catch (e) {
      state = previousState; // Rollback
    }
  }

  Future<void> updateProject(
      String id, String newName, String newDescription) async {
    if (state is AsyncLoading || !state.hasValue) return;

    final project = state.value!.firstWhere((p) => p.id == id).copyWith(
          name: newName,
          description: newDescription,
        );

    final previousState = state;
    state = AsyncValue.data([
      for (final p in state.value!)
        if (p.id == id) project else p
    ]);

    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.updateProject(project);
    } catch (e) {
      state = previousState; // Rollback
    }
  }

  Future<void> deleteProject(String id) async {
    if (state is AsyncLoading || !state.hasValue) return;

    final previousState = state;
    state = AsyncValue.data(state.value!.where((p) => p.id != id).toList());

    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.deleteProject(id);
    } catch (e) {
      state = previousState; // Rollback
    }
  }
}
