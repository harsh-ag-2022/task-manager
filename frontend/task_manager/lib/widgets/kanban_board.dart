import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'kanban_column.dart';

class KanbanBoard extends ConsumerWidget {
  final String searchQuery;
  final bool Function(Task) isTaskBlocked;

  const KanbanBoard({
    super.key,
    required this.searchQuery,
    required this.isTaskBlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    var tasks = taskState.allTasks;
    if (searchQuery.isNotEmpty) {
      tasks = tasks.where((t) => t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

    void onTaskDropped(Task task, TaskStatus newStatus) {
      ref.read(taskProvider.notifier).updateTaskStatusOptimistically(task, newStatus);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanbanColumn(
            title: 'To-Do',
            status: TaskStatus.todo,
            tasks: todoTasks,
            searchQuery: searchQuery,
            onTaskDropped: onTaskDropped,
            isTaskBlocked: isTaskBlocked,
          ),
          KanbanColumn(
            title: 'In Progress',
            status: TaskStatus.inProgress,
            tasks: inProgressTasks,
            searchQuery: searchQuery,
            onTaskDropped: onTaskDropped,
            isTaskBlocked: isTaskBlocked,
          ),
          KanbanColumn(
            title: 'Done',
            status: TaskStatus.done,
            tasks: doneTasks,
            searchQuery: searchQuery,
            onTaskDropped: onTaskDropped,
            isTaskBlocked: isTaskBlocked,
          ),
        ],
      ),
    );
  }
}
