import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tidytask/data/repositories/task_repository_impl.dart';
import 'package:tidytask/presentation/viewmodels/task_viewmodel.dart';
import 'package:tidytask/domain/entities/task.dart';
import 'package:tidytask/core/services/notification_service.dart';
import 'package:tidytask/core/di/service_locator.dart';
import 'task_viewmodel_test.mocks.dart';

@GenerateMocks([TaskRepositoryImpl, NotificationService])
void main() {
  late TaskViewModel viewModel;
  late MockTaskRepositoryImpl mockRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockRepository = MockTaskRepositoryImpl();
    mockNotificationService = MockNotificationService();

    
    if (getIt.isRegistered<TaskRepositoryImpl>()) {
      getIt.unregister<TaskRepositoryImpl>();
    }
    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }

    getIt.registerSingleton<TaskRepositoryImpl>(mockRepository);
    getIt.registerSingleton<NotificationService>(mockNotificationService);

    
    viewModel = TaskViewModel();
  });

  final testTask = Task(
    id: '1',
    title: 'Test Task',
    createdAt: DateTime.now(),
    priority: TaskPriority.high,
  );

  group('TaskViewModel', () {
    test('initial state should be empty', () {
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('loadTasks should update tasks list', () async {
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [testTask]);

      await viewModel.loadTasks();

      expect(viewModel.tasks.length, equals(1));
      expect(viewModel.tasks.first.id, equals(testTask.id));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('loadTasks should handle errors', () async {
      when(mockRepository.getAllTasks())
          .thenThrow(Exception('Failed to load tasks'));

      await viewModel.loadTasks();

      expect(viewModel.tasks, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
    });

    test('createTask should add task and schedule notification', () async {
      when(mockRepository.createTask(testTask)).thenAnswer((_) async {});
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [testTask]);

      await viewModel.createTask(testTask);

      verify(mockRepository.createTask(testTask));
      verify(mockNotificationService.scheduleTaskReminder(testTask));
      expect(viewModel.tasks.length, equals(1));
    });

    test('updateTask should update task and handle notifications', () async {
      final updatedTask = testTask.copyWith(isCompleted: true);

      when(mockRepository.updateTask(updatedTask)).thenAnswer((_) async {});
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [updatedTask]);

      await viewModel.updateTask(updatedTask);

      verify(mockRepository.updateTask(updatedTask));
      verify(mockNotificationService.cancelTaskReminder(updatedTask));
      expect(viewModel.tasks.first.isCompleted, isTrue);
    });

    test('deleteTask should remove task and cancel notification', () async {
      
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => [testTask]);
      await viewModel.loadTasks();
      
      
      when(mockRepository.deleteTask(testTask.id))
          .thenAnswer((_) async {});
      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => []);

      await viewModel.deleteTask(testTask.id);

      verify(mockRepository.deleteTask(testTask.id));
      verify(mockNotificationService.cancelTaskReminder(testTask));
      expect(viewModel.tasks, isEmpty);
    });

    test('filtered tasks should respect filter settings', () async {
      final completedTask = testTask.copyWith(isCompleted: true);
      final incompletedTask = Task(
        id: '2',
        title: 'Test Task 2',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        isCompleted: false,
      );

      when(mockRepository.getAllTasks())
          .thenAnswer((_) async => [completedTask, incompletedTask]);

      await viewModel.loadTasks();
      viewModel.toggleShowCompleted(); 

      expect(viewModel.filteredTasks.length, equals(1));
      expect(viewModel.filteredTasks.first.id, equals(incompletedTask.id));
    });
  });
}
