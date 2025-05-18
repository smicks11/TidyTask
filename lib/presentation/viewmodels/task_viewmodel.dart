import 'package:flutter/foundation.dart';
import 'package:tidytask/core/services/notification_service.dart';
import '../../domain/entities/task.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../core/di/service_locator.dart';

class TaskViewModel extends ChangeNotifier {
  final _repository = getIt<TaskRepositoryImpl>();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  TaskSortType _sortType = TaskSortType.date;
  String? _filterTag;
  TaskPriority? _filterPriority;
  bool _showCompleted = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    try {
      await _repository.createTask(task);
      await getIt<NotificationService>().scheduleTaskReminder(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await getIt<NotificationService>().cancelTaskReminder(task);
      if (!task.isCompleted) {
        await getIt<NotificationService>().scheduleTaskReminder(task);
      }
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      await _repository.deleteTask(id);
      await getIt<NotificationService>().cancelTaskReminder(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  TaskSortType get sortType => _sortType;
  String? get filterTag => _filterTag;
  TaskPriority? get filterPriority => _filterPriority;
  bool get showCompleted => _showCompleted;

  List<Task> get filteredTasks {
    var filtered = _tasks;
    
    if (!_showCompleted) {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }
    
    if (_filterTag != null) {
      filtered = filtered.where((task) => task.tags.contains(_filterTag)).toList();
    }
    
    if (_filterPriority != null) {
      filtered = filtered.where((task) => task.priority == _filterPriority).toList();
    }
    
    switch (_sortType) {
      case TaskSortType.date:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortType.priority:
        filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TaskSortType.deadline:
        filtered.sort((a, b) {
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
    }
    
    return filtered;
  }

  void setSortType(TaskSortType type) {
    _sortType = type;
    notifyListeners();
  }

  void setFilterTag(String? tag) {
    _filterTag = tag;
    notifyListeners();
  }

  void setFilterPriority(TaskPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }
}

enum TaskSortType {
  date,
  priority,
  deadline,
}