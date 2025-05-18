import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tidytask/data/datasources/local/database_helper.dart';
import 'package:tidytask/data/models/task_model.dart';
import 'package:tidytask/data/repositories/task_repository_impl.dart';
import 'package:tidytask/domain/entities/task.dart';
import 'task_repository_impl_test.mocks.dart';  

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late TaskRepositoryImpl repository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    repository = TaskRepositoryImpl(mockDatabaseHelper);
  });

  final testTask = TaskModel(
    id: '1',
    title: 'Test Task',
    createdAt: DateTime.now(),
    priority: TaskPriority.high,
  );

  group('getAllTasks', () {
    test('should return list of tasks from database', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query('tasks')).thenAnswer((_) async => [testTask.toJson()]);

      final result = await repository.getAllTasks();

      expect(result, isA<List<Task>>());
      expect(result.length, 1);
      expect(result.first.id, testTask.id);
      verify(mockDatabase.query('tasks'));
    });
  });

  group('createTask', () {
    test('should insert task into database', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.insert(
        'tasks',
        testTask.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).thenAnswer((_) async => 1);

      await repository.createTask(testTask);

      verify(mockDatabase.insert(
        'tasks',
        testTask.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ));
    });
  });

  group('getTaskById', () {
    test('should return task when found', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [testTask.id],
      )).thenAnswer((_) async => [testTask.toJson()]);

      final result = await repository.getTaskById(testTask.id);

      expect(result, isNotNull);
      expect(result?.id, testTask.id);
    });

    test('should return null when task not found', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [testTask.id],
      )).thenAnswer((_) async => []);

      
      final result = await repository.getTaskById(testTask.id);

      
      expect(result, isNull);
    });
  });

  group('getTasksByPriority', () {
    test('should return tasks with specified priority', () async {
      final highPriorityTask = testTask;
      final lowPriorityTask = TaskModel(
        id: '2',
        title: 'Low Priority Task',
        createdAt: DateTime.now(),
        priority: TaskPriority.low,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'tasks',
        where: 'priority = ?',
        whereArgs: [TaskPriority.high.toString()],
      )).thenAnswer((_) async => [highPriorityTask.toJson()]);

      final result = await repository.getTasksByPriority(TaskPriority.high);

      expect(result.length, 1);
      expect(result.first.priority, TaskPriority.high);
      verify(mockDatabase.query(
        'tasks',
        where: 'priority = ?',
        whereArgs: [TaskPriority.high.toString()],
      ));
    });
  });

  group('getTasksByDeadline', () {
    test('should return tasks due before specified deadline', () async {
      final deadline = DateTime.now().add(const Duration(days: 1));
      final taskWithDeadline = TaskModel(
        id: '3',
        title: 'Deadline Task',
        createdAt: DateTime.now(),
        deadline: deadline,
        priority: TaskPriority.medium,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'tasks',
        where: 'deadline <= ?',
        whereArgs: [deadline.millisecondsSinceEpoch],
      )).thenAnswer((_) async => [taskWithDeadline.toJson()]);

      final result = await repository.getTasksByDeadline(deadline);

      expect(result.length, 1);
      expect(result.first.deadline!.isBefore(deadline) || 
             result.first.deadline!.isAtSameMomentAs(deadline), true);
    });
  });

  group('updateTask', () {
    test('should update existing task in database', () async {
      final updatedTask = testTask.copyWith(
        title: 'Updated Task Title',
        priority: TaskPriority.urgent,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.update(
        'tasks',
        updatedTask.toJson(),
        where: 'id = ?',
        whereArgs: [updatedTask.id],
      )).thenAnswer((_) async => 1);

      await repository.updateTask(updatedTask);

      verify(mockDatabase.update(
        'tasks',
        updatedTask.toJson(),
        where: 'id = ?',
        whereArgs: [updatedTask.id],
      ));
    });
  });

  group('deleteTask', () {
    test('should delete task from database', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [testTask.id],
      )).thenAnswer((_) async => 1);

      await repository.deleteTask(testTask.id);

      verify(mockDatabase.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [testTask.id],
      ));
    });

    test('should handle deletion of non-existent task', () async {
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: ['non-existent-id'],
      )).thenAnswer((_) async => 0);

      await repository.deleteTask('non-existent-id');

      verify(mockDatabase.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: ['non-existent-id'],
      ));
    });
  });
}