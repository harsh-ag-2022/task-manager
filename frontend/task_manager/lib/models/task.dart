enum TaskStatus {
  todo,
  inProgress,
  done,
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
  });

  static TaskStatus _statusFromJson(String status) {
    switch (status) {
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Done':
        return TaskStatus.done;
      case 'To-Do':
      default:
        return TaskStatus.todo;
    }
  }

  static String _statusToJson(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.todo:
        return 'To-Do';
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: _statusFromJson(json['status'] as String),
      blockedById: json['blocked_by_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': _statusToJson(status),
      'blocked_by_id': blockedById,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
    );
  }
}
