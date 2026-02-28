import 'task_data_model.dart';

abstract class TaskRepository {
  Future<List<TaskDataModel>> getTasks();
  Future<void> addTask(TaskDataModel task);
  Future<void> updateTask(TaskDataModel task);
}
