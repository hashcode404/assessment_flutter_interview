import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import 'domain/task_data_model.dart';
import 'domain/task_repository.dart';
import 'data/data_sources/task_local_data_source.dart';
import 'data/data_sources/task_remote_data_source.dart';
import 'data/repositories/task_repository_impl.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl();
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TaskRemoteDataSourceImpl(firestore: firestore);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
});

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskDataModel>>(() {
  return TasksNotifier();
});

class TasksNotifier extends AsyncNotifier<List<TaskDataModel>> {
  @override
  Future<List<TaskDataModel>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    return await repository.getTasks();
  }

  Future<void> updateTaskStage(TaskDataModel task, TaskType newStage) async {
    if (state is AsyncLoading || !state.hasValue) return;

    final updatedTask = TaskDataModel(
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      stage: newStage,
    );

    final previousState = state;
    state = AsyncValue.data([
      for (final t in state.value!)
        if (t.id == task.id) updatedTask else t,
    ]);

    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.updateTask(updatedTask);

      ref.read(notificationServiceProvider).showLocalNotification(
            id: updatedTask.id.hashCode,
            title: 'Task Updated',
            body:
                'Moved "${updatedTask.title}" to ${newStage.name.toUpperCase()}',
          );
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> addTask(
      String title, String description, String projectId) async {
    if (state is AsyncLoading) return;

    final newTask = TaskDataModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      projectId: projectId,
      stage: TaskType.todo,
    );

    final previousState = state;
    if (previousState.hasValue) {
      state = AsyncValue.data([...previousState.value!, newTask]);
    }

    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.addTask(newTask);

      ref.read(notificationServiceProvider).showLocalNotification(
            id: newTask.id.hashCode,
            title: 'Task Created',
            body: 'Successfully created task "${newTask.title}"',
          );
    } catch (e) {
      state = previousState;
    }
  }
}
