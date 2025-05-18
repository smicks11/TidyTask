import 'package:flutter/foundation.dart';

@immutable
class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final List<String> tags;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.tags = const [],
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent
}