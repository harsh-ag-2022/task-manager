import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

class DraftState {
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final int? blockedBy;

  DraftState({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedBy,
  });

  DraftState copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedBy,
  }) {
    return DraftState(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }
}

class DraftNotifier extends Notifier<DraftState> {
  @override
  DraftState build() {
    return DraftState();
  }

  void updateDraft({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedBy,
  }) {
    state = state.copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      blockedBy: blockedBy,
    );
  }

  void clearDraft() {
    state = DraftState();
  }
}

final draftProvider = NotifierProvider<DraftNotifier, DraftState>(DraftNotifier.new);

