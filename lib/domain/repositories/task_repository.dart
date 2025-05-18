import 'package:tidytask/domain/entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> getTasksByPriority(TaskPriority priority);
  Future<List<Task>> getTasksByDeadline(DateTime deadline);
  Future<List<Task>> searchTasks(String query);
}