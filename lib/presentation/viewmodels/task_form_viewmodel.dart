import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';

class TaskFormViewModel extends ChangeNotifier {
  String _title = '';
  String _description = '';
  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.medium;
  final List<String> _tags = [];
  String? _error;
  final Task? _existingTask;

  TaskFormViewModel({Task? task}) : _existingTask = task {
    if (task != null) {
      _title = task.title;
      _description = task.description ?? '';
      _deadline = task.deadline;
      _priority = task.priority;
      _tags.addAll(task.tags);
    }
  }

  // Getters
  String get title => _title;
  String get description => _description;
  DateTime? get deadline => _deadline;
  TaskPriority get priority => _priority;
  List<String> get tags => List.unmodifiable(_tags);
  String? get error => _error;
  bool get isEditing => _existingTask != null;

  void setTitle(String value) {
    _title = value.trim();
    _validateForm();
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value.trim();
    notifyListeners();
  }

  void setDeadline(DateTime? value) {
    _deadline = value;
    notifyListeners();
  }

  void setPriority(TaskPriority value) {
    _priority = value;
    notifyListeners();
  }

  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      _tags.add(trimmedTag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void _validateForm() {
    if (_title.isEmpty) {
      _error = 'Title is required';
    } else {
      _error = null;
    }
  }

  Task? createTask() {
    if (_title.isEmpty) {
      _error = 'Title is required';
      notifyListeners();
      return null;
    }

    final task = Task(
      id: _existingTask?.id ?? const Uuid().v4(),
      title: _title,
      description: _description.isEmpty ? null : _description,
      createdAt: _existingTask?.createdAt ?? DateTime.now(),
      deadline: _deadline,
      priority: _priority,
      isCompleted: _existingTask?.isCompleted ?? false,
      tags: _tags,
    );

    return task;
  }
}
