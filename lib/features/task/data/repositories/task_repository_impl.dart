import 'package:flutter/foundation.dart';
import '../../domain/task_data_model.dart';
import '../../domain/task_repository.dart';
import '../data_sources/task_local_data_source.dart';
import '../data_sources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<TaskDataModel>> getTasks() async {
    try {
      final remoteTasks = await remoteDataSource.getTasks();
      if (remoteTasks.isNotEmpty) {
        await localDataSource.cacheTasks(remoteTasks);
        return remoteTasks;
      } else {
        return await localDataSource.getCachedTasks();
      }
    } catch (e) {
      debugPrint('Firebase getTasks Error: $e');
      return await localDataSource.getCachedTasks();
    }
  }

  @override
  Future<void> addTask(TaskDataModel task) async {
    try {
      await remoteDataSource.addTask(task);
    } catch (e) {
      debugPrint('Firebase addTask Error: $e');
    }
    final tasks = await localDataSource.getCachedTasks();
    tasks.add(task);
    await localDataSource.cacheTasks(tasks);
  }

  @override
  Future<void> updateTask(TaskDataModel task) async {
    try {
      await remoteDataSource.updateTask(task);
    } catch (e) {
      debugPrint('Firebase updateTask Error: $e');
    }
    final tasks = await localDataSource.getCachedTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await localDataSource.cacheTasks(tasks);
    }
  }
}
