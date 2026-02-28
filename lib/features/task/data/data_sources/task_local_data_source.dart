import 'package:hive/hive.dart';
import '../../domain/task_data_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskDataModel>> getCachedTasks();
  Future<void> cacheTasks(List<TaskDataModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const boxName = 'tasksBox';

  @override
  Future<List<TaskDataModel>> getCachedTasks() async {
    final box = await Hive.openBox<TaskDataModel>(boxName);
    return box.values.toList();
  }

  @override
  Future<void> cacheTasks(List<TaskDataModel> tasks) async {
    final box = await Hive.openBox<TaskDataModel>(boxName);
    await box.clear();
    await box.addAll(tasks);
  }
}
