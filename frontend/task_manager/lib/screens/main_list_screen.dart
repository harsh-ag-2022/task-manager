import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/kanban_board.dart';
import 'task_form_screen.dart';

class MainListScreen extends ConsumerStatefulWidget {
  const MainListScreen({super.key});

  @override
  ConsumerState<MainListScreen> createState() => _MainListScreenState();
}

class _MainListScreenState extends ConsumerState<MainListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _searchQuery = '';
  bool _isKanbanView = false;

  final List<String> _filters = ['All', 'To-Do', 'In Progress', 'Done'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    ref.read(taskProvider.notifier).debouncedSearch(
      query,
      status: _selectedStatus == 'All' ? null : _selectedStatus,
    );
  }

  void _onStatusChanged(String newValue) {
    setState(() {
      _selectedStatus = newValue;
    });
    ref.read(taskProvider.notifier).debouncedSearch(
      _searchController.text,
      status: newValue == 'All' ? null : newValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
                      (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final colorScheme = Theme.of(context).colorScheme;

    return LoadingOverlay(
      isLoading: taskState.isLoading,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(taskProvider.notifier).fetchTasks();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  'My Tasks',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                centerTitle: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                scrolledUnderElevation: 0,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 28, 
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    tooltip: 'Toggle Theme',
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle, size: 32, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar & View Toggle
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: isDarkMode ? Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)) : null,
                                boxShadow: isDarkMode ? null : [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.outfit(fontSize: 16, color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  hintStyle: GoogleFonts.outfit(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // View Toggle Buttons
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: isDarkMode ? Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)) : null,
                              boxShadow: isDarkMode ? null : [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.view_list_rounded),
                                  color: !_isKanbanView ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
                                  onPressed: () => setState(() => _isKanbanView = false),
                                  tooltip: 'List View',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.view_week_rounded),
                                  color: _isKanbanView ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
                                  onPressed: () => setState(() => _isKanbanView = true),
                                  tooltip: 'Kanban View',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!_isKanbanView) ...[
                        const SizedBox(height: 20),
                        // Filter Chips
                        SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedStatus == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(
                                  filter,
                                  style: GoogleFonts.outfit(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? colorScheme.surface : colorScheme.onSurface,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _onStatusChanged(filter);
                                  }
                                },
                                selectedColor: colorScheme.primary, // Indigo
                                backgroundColor: Theme.of(context).cardTheme.color,
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ],
                      if (taskState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Error: ${taskState.error}',
                            style: GoogleFonts.outfit(color: colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (taskState.tasks.isEmpty && taskState.error == null && !taskState.isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isKanbanView)
                SliverFillRemaining(
                  child: KanbanBoard(
                    searchQuery: _searchQuery,
                    isTaskBlocked: (task) {
                      if (task.blockedBy == null) return false;
                      final blockingTaskIndex = taskState.allTasks.indexWhere((t) => t.id == task.blockedBy);
                      if (blockingTaskIndex != -1) {
                        return taskState.allTasks[blockingTaskIndex].status != TaskStatus.done;
                      }
                      return true;
                    },
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = taskState.tasks[index];
                      // Determine if the task is blocked
                      bool isBlocked = false;
                      if (task.blockedBy != null) {
                        final blockingTaskIndex = taskState.allTasks.indexWhere((t) => t.id == task.blockedBy);
                        if (blockingTaskIndex != -1) {
                          final blockingTask = taskState.allTasks[blockingTaskIndex];
                          if (blockingTask.status != TaskStatus.done) {
                            isBlocked = true;
                          }
                        } else {
                          isBlocked = true; 
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == taskState.tasks.length - 1 ? 80.0 : 0, // Padding for FAB
                        ),
                        child: TaskCard(
                          task: task,
                          isBlocked: isBlocked,
                          searchQuery: _searchQuery,
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
                    childCount: taskState.tasks.length,
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary.withValues(alpha: 0.8)], // Primary to a variant
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const TaskFormScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
