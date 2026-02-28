import 'project_data_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectDataModel>> getProjects();
  Future<void> addProject(ProjectDataModel project);
  Future<void> updateProject(ProjectDataModel project);
  Future<void> deleteProject(String id);
}
