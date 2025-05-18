import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import '../datasources/local/database_helper.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final DatabaseHelper _databaseHelper;

  TaskRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Task>> getAllTasks() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return TaskModel.fromJson(maps[i]);
    });
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TaskModel.fromJson(maps.first);
  }

  @override
  Future<void> createTask(Task task) async {
    final db = await _databaseHelper.database;
    final taskModel = TaskModel.fromTask(task);
    await db.insert(
      'tasks',
      taskModel.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await _databaseHelper.database;
    final taskModel = TaskModel.fromTask(task);
    await db.update(
      'tasks',
      taskModel.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority.toString()],
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Task>> getTasksByDeadline(DateTime deadline) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'deadline <= ?',
      whereArgs: [deadline.millisecondsSinceEpoch],
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Task>> searchTasks(String query) {
    // TODO: implement searchTasks
    throw UnimplementedError();
  }
}
