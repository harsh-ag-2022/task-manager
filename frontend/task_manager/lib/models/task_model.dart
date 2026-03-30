enum TaskStatus { todo, inProgress, done }

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final int? blockedBy;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedBy,
  });

  static TaskStatus _statusFromJson(String status) {
    if (status == 'In Progress') return TaskStatus.inProgress;
    if (status == 'Done') return TaskStatus.done;
    return TaskStatus.todo;
  }

  static String _statusToJson(TaskStatus status) {
    if (status == TaskStatus.inProgress) return 'In Progress';
    if (status == TaskStatus.done) return 'Done';
    return 'To-Do';
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: _statusFromJson(json['status'] ?? 'To-Do'),
      blockedBy: json['blocked_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': _statusToJson(status),
      if (blockedBy != null) 'blocked_by': blockedBy,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedBy,
    bool clearBlockedBy = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: clearBlockedBy ? null : (blockedBy ?? this.blockedBy),
    );
  }
}

