import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    DateTime? deadline,
    TaskPriority priority = TaskPriority.medium,
    bool isCompleted = false,
    List<String> tags = const [],
  }) : super(
          id: id,
          title: title,
          description: description,
          createdAt: createdAt,
          deadline: deadline,
          priority: priority,
          isCompleted: isCompleted,
          tags: tags,
        );

  factory TaskModel.fromTask(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      deadline: task.deadline,
      priority: task.priority,
      isCompleted: task.isCompleted,
      tags: task.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'priority': priority.toString(),
      'is_completed': isCompleted ? 1 : 0,
      'tags': tags.join(','),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      deadline: json['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'] as int)
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['is_completed'] == 1,
      tags: json['tags'] != null ? (json['tags'] as String).split(',') : [],
    );
  }

  @override
  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return TaskModel(
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
