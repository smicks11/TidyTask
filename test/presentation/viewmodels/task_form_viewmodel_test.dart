import 'package:flutter_test/flutter_test.dart';
import 'package:tidytask/presentation/viewmodels/task_form_viewmodel.dart';
import 'package:tidytask/domain/entities/task.dart';

void main() {
  group('TaskFormViewModel', () {
    late TaskFormViewModel viewModel;

    setUp(() {
      viewModel = TaskFormViewModel();
    });

    test('initial state should be empty', () {
      expect(viewModel.title, isEmpty);
      expect(viewModel.description, isEmpty);
      expect(viewModel.deadline, isNull);
      expect(viewModel.priority, equals(TaskPriority.medium));
      expect(viewModel.tags, isEmpty);
      expect(viewModel.error, isNull);
      expect(viewModel.isEditing, isFalse);
    });

    test('setTitle should update title and validate form', () {
      viewModel.setTitle('New Task');
      expect(viewModel.title, equals('New Task'));
      expect(viewModel.error, isNull);
    });

    test('setDescription should update description', () {
      viewModel.setDescription('Task description');
      expect(viewModel.description, equals('Task description'));
    });

    test('setDeadline should update deadline', () {
      final deadline = DateTime.now();
      viewModel.setDeadline(deadline);
      expect(viewModel.deadline, equals(deadline));
    });

    test('setPriority should update priority', () {
      viewModel.setPriority(TaskPriority.high);
      expect(viewModel.priority, equals(TaskPriority.high));
    });

    test('addTag should add new tag', () {
      viewModel.addTag('important');
      expect(viewModel.tags, contains('important'));
    });

    test('addTag should not add duplicate tag', () {
      viewModel.addTag('important');
      viewModel.addTag('important');
      expect(viewModel.tags.where((tag) => tag == 'important').length, equals(1));
    });

    test('removeTag should remove existing tag', () {
      viewModel.addTag('important');
      viewModel.removeTag('important');
      expect(viewModel.tags, isEmpty);
    });

    test('createTask should return null when title is empty', () {
      expect(viewModel.createTask(), isNull);
      expect(viewModel.error, isNotNull);
    });

    test('createTask should return task when valid', () {
      viewModel.setTitle('Test Task');
      final task = viewModel.createTask();
      expect(task, isNotNull);
      expect(task!.title, equals('Test Task'));
      expect(task.priority, equals(TaskPriority.medium));
    });

    test('initialization with existing task should populate fields', () {
      final existingTask = Task(
        id: '1',
        title: 'Existing Task',
        description: 'Description',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        tags: const ['important'],
      );

      final viewModel = TaskFormViewModel(task: existingTask);
      expect(viewModel.title, equals('Existing Task'));
      expect(viewModel.description, equals('Description'));
      expect(viewModel.priority, equals(TaskPriority.high));
      expect(viewModel.tags, contains('important'));
      expect(viewModel.isEditing, isTrue);
    });
  });
}