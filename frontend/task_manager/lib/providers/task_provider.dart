import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class TaskState {
  final List<Task> allTasks;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String statusFilter;
  
  TaskState({
    this.allTasks = const [], 
    this.isLoading = false, 
    this.error,
    this.searchQuery = '',
    this.statusFilter = 'All',
  });
  
  List<Task> get tasks {
    var filtered = allTasks;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (statusFilter != 'All' && statusFilter.isNotEmpty) {
      final statusEnum = statusFilter == 'To-Do' ? TaskStatus.todo 
                       : statusFilter == 'In Progress' ? TaskStatus.inProgress 
                       : TaskStatus.done;
      filtered = filtered.where((t) => t.status == statusEnum).toList();
    }
    return filtered;
  }
  
  TaskState copyWith({
    List<Task>? allTasks,
    bool? isLoading, 
    String? error,
    String? searchQuery,
    String? statusFilter,
  }) {
    return TaskState(
      allTasks: allTasks ?? this.allTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class TaskNotifier extends Notifier<TaskState> {
  Timer? _debounceTimer;

  @override
  TaskState build() {
    Future.microtask(() => fetchTasks());
    return TaskState();
  }

  Future<void> fetchTasks() async {
    final apiService = ref.read(apiServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final allTasks = await apiService.fetchTasks();
      state = state.copyWith(allTasks: allTasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void debouncedSearch(String query, {String? status}) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    // Update local state instantly rather than waiting for server
    state = state.copyWith(searchQuery: query, statusFilter: status ?? 'All');
  }

  Future<void> addTask(Task task) async {
    final apiService = ref.read(apiServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      await apiService.createTask(task);
      // Re-fetch all tasks to ensure filtering is re-applied correctly
      fetchTasks();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTask(Task task) async {
    final apiService = ref.read(apiServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedTask = await apiService.updateTask(task);
      final updatedAllTasks = state.allTasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
      state = state.copyWith(allTasks: updatedAllTasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteTask(int id) async {
    final apiService = ref.read(apiServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      await apiService.deleteTask(id);
      final updatedAllTasks = state.allTasks
          .where((t) => t.id != id)
          .map((t) => t.blockedBy == id ? t.copyWith(clearBlockedBy: true) : t)
          .toList();
      state = state.copyWith(allTasks: updatedAllTasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTaskStatusOptimistically(Task task, TaskStatus newStatus) async {
    final apiService = ref.read(apiServiceProvider);
    
    // Save old state in case of failure
    final oldState = state;
    
    // Optimistic update
    final optimisticTask = task.copyWith(status: newStatus);
    final updatedAllTasks = state.allTasks.map((t) => t.id == task.id ? optimisticTask : t).toList();
    
    // Update state immediately without triggering the full screen loading overlay
    state = state.copyWith(allTasks: updatedAllTasks, error: null);
    
    try {
      final updatedTask = await apiService.updateTask(optimisticTask);
      final finalAllTasks = state.allTasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
      state = state.copyWith(allTasks: finalAllTasks);
    } catch (e) {
      // Revert on error
      state = oldState.copyWith(error: e.toString());
    }
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(TaskNotifier.new);
