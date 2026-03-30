import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/draft_provider.dart';
import '../widgets/loading_overlay.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task; // If null, we are creating a new task

  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _blockedByController;
  DateTime? _selectedDueDate;
  TaskStatus _selectedStatus = TaskStatus.todo;

  @override
  void initState() {
    super.initState();
    
    // If editing an existing task, initialize with its values
    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(text: widget.task!.description);
      _blockedByController = TextEditingController(text: widget.task!.blockedBy?.toString() ?? '');
      _selectedDueDate = widget.task!.dueDate;
      _selectedStatus = widget.task!.status;
    } else {
      // If creating new task, initialize with DraftState
      final draft = ref.read(draftProvider);
      _titleController = TextEditingController(text: draft.title);
      _descriptionController = TextEditingController(text: draft.description);
      _blockedByController = TextEditingController(text: draft.blockedBy?.toString() ?? '');
      _selectedDueDate = draft.dueDate;
      _selectedStatus = draft.status;
    }

    // Add listeners to save draft if creating new
    if (widget.task == null) {
      _titleController.addListener(_updateDraft);
      _descriptionController.addListener(_updateDraft);
      _blockedByController.addListener(_updateDraft);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _blockedByController.dispose();
    super.dispose();
  }

  void _updateDraft() {
    if (widget.task == null) {
      ref.read(draftProvider.notifier).updateDraft(
        title: _titleController.text,
        description: _descriptionController.text,
        blockedBy: int.tryParse(_blockedByController.text),
        dueDate: _selectedDueDate,
        status: _selectedStatus,
      );
    }
  }

  Future<void> _selectDueDate() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary, // header background color
              onPrimary: colorScheme.onPrimary, // header text color
              onSurface: colorScheme.onSurface, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
      _updateDraft();
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a due date', style: GoogleFonts.outfit())),
        );
        return;
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDueDate!,
        status: _selectedStatus,
        blockedBy: int.tryParse(_blockedByController.text),
      );

      final notifier = ref.read(taskProvider.notifier);
      
      try {
        if (widget.task == null) {
          await notifier.addTask(task);
          ref.read(draftProvider.notifier).clearDraft();
        } else {
          await notifier.updateTask(task);
        }
        
        if (mounted) {
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving task: $e', style: GoogleFonts.outfit())),
          );
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
    ); // Let AppTheme handle the styling!
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskProvider).isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.task == null ? 'Create Task' : 'Edit Task #${widget.task!.id ?? ""}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          actions: [
            if (widget.task != null)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: theme.cardTheme.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('Delete Task', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      content: Text('Are you sure you want to delete this task?', style: GoogleFonts.outfit(color: colorScheme.onSurface)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: GoogleFonts.outfit(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Delete', style: GoogleFonts.outfit(color: colorScheme.error, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && widget.task!.id != null) {
                    await ref.read(taskProvider.notifier).deleteTask(widget.task!.id!);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.outfit(fontSize: 16, color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration('Task Title', 'E.g., Design Landing Page'),
                    validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    style: GoogleFonts.outfit(fontSize: 16, color: colorScheme.onSurface),
                    decoration: _inputDecoration('Description', 'Detailed description of the task...'),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 20),
                  // Due Date
                  InkWell(
                    onTap: _selectDueDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        border: theme.inputDecorationTheme.enabledBorder?.borderSide != null 
                            ? Border.fromBorderSide(theme.inputDecorationTheme.enabledBorder!.borderSide)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calendar_month_rounded, color: colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due Date', style: GoogleFonts.outfit(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDueDate != null 
                                    ? _selectedDueDate!.toIso8601String().split('T')[0] 
                                    : 'Select a date',
                                  style: GoogleFonts.outfit(
                                    color: _selectedDueDate != null ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4), 
                                    fontSize: 16,
                                    fontWeight: _selectedDueDate != null ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Status
                  DropdownButtonFormField<TaskStatus>(
                    initialValue: _selectedStatus,
                    style: GoogleFonts.outfit(fontSize: 16, color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                    decoration: _inputDecoration('Status', 'Select task status'),
                    icon: Icon(Icons.expand_more_rounded, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    dropdownColor: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    items: [
                      DropdownMenuItem(value: TaskStatus.todo, child: Text('To-Do', style: GoogleFonts.outfit())),
                      DropdownMenuItem(value: TaskStatus.inProgress, child: Text('In Progress', style: GoogleFonts.outfit())),
                      DropdownMenuItem(value: TaskStatus.done, child: Text('Done', style: GoogleFonts.outfit())),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                        _updateDraft();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _blockedByController,
                    style: GoogleFonts.outfit(fontSize: 16, color: colorScheme.onSurface),
                    decoration: _inputDecoration('Blocked By (Task ID)', 'E.g., 42').copyWith(
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.tertiary], 
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        widget.task == null ? 'Create Task' : 'Save Changes',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
