import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/project_data_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectDataModel>> getProjects();
  Future<void> addProject(ProjectDataModel project);
  Future<void> updateProject(ProjectDataModel project);
  Future<void> deleteProject(String id);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ProjectDataModel>> getProjects() async {
    final querySnapshot = await firestore.collection('projects').get();
    final projects = <ProjectDataModel>[];
    for (var doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;

        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        projects.add(ProjectDataModel.fromJson(data));
      } catch (e) {
        debugPrint('Error parsing project ${doc.id}: $e');
      }
    }
    return projects;
  }

  @override
  Future<void> addProject(ProjectDataModel project) async {
    await firestore
        .collection('projects')
        .doc(project.id)
        .set(project.toJson());
  }

  @override
  Future<void> updateProject(ProjectDataModel project) async {
    await firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }

  @override
  Future<void> deleteProject(String id) async {
    await firestore.collection('projects').doc(id).delete();
  }
}
