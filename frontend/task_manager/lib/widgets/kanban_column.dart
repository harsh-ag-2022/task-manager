import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../screens/task_form_screen.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<Task> tasks;
  final String searchQuery;
  final void Function(Task, TaskStatus) onTaskDropped;
  final bool Function(Task) isTaskBlocked;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.searchQuery,
    required this.onTaskDropped,
    required this.isTaskBlocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final task = details.data;
        if (isTaskBlocked(task) && status != TaskStatus.todo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot move a blocked task to ${status == TaskStatus.inProgress ? "In Progress" : "Done"}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        onTaskDropped(task, status);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark 
                ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: candidateData.isNotEmpty
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: GoogleFonts.outfit(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List of tasks
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final blocked = isTaskBlocked(task);
                    return LongPressDraggable<Task>(
                      data: task,
                      delay: const Duration(milliseconds: 200),
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                           width: 320,
                           child: Opacity(
                             opacity: 0.9,
                             child: Transform.scale(
                               scale: 1.02,
                               child: TaskCard(
                                 task: task,
                                 isBlocked: blocked,
                                 searchQuery: searchQuery,
                                 onTap: () {},
                               ),
                             ),
                           ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: TaskCard(
                          task: task,
                          isBlocked: blocked,
                          searchQuery: searchQuery,
                          onTap: () {},
                        ),
                      ),
                      child: TaskCard(
                        task: task,
                        isBlocked: blocked,
                        searchQuery: searchQuery,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => TaskFormScreen(task: task),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(position: animation.drive(tween), child: child);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
