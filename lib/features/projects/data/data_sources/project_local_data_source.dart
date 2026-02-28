import 'package:hive/hive.dart';
import '../../domain/project_data_model.dart';

abstract class ProjectLocalDataSource {
  Future<List<ProjectDataModel>> getCachedProjects();
  Future<void> cacheProjects(List<ProjectDataModel> projects);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  // Hive box name
  static const boxName = 'projectsBox';

  @override
  Future<List<ProjectDataModel>> getCachedProjects() async {
    final box = await Hive.openBox<ProjectDataModel>(boxName);
    return box.values.toList();
  }

  @override
  Future<void> cacheProjects(List<ProjectDataModel> projects) async {
    final box = await Hive.openBox<ProjectDataModel>(boxName);
    await box.clear(); // Clear existing cache
    await box.addAll(projects);
  }
}
