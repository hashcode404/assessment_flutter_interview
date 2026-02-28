import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/task_data_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskDataModel>> getTasks();
  Future<void> addTask(TaskDataModel task);
  Future<void> updateTask(TaskDataModel task);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TaskDataModel>> getTasks() async {
    final querySnapshot = await firestore.collection('tasks').get();
    final tasks = <TaskDataModel>[];
    for (var doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        tasks.add(TaskDataModel.fromJson(data));
      } catch (e) {
        debugPrint('Error parsing task ${doc.id}: $e');
      }
    }
    return tasks;
  }

  @override
  Future<void> addTask(TaskDataModel task) async {
    await firestore.collection('tasks').doc(task.id).set(task.toJson());
  }

  @override
  Future<void> updateTask(TaskDataModel task) async {
    await firestore.collection('tasks').doc(task.id).update(task.toJson());
  }
}
