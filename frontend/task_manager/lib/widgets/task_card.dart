import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final String searchQuery;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    this.searchQuery = '',
    required this.onTap,
  });

  List<TextSpan> _highlightSearchTerm(String text, String query, bool blocked, ColorScheme colorScheme) {
    final baseColor = blocked ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface;
    if (query.isEmpty) return [TextSpan(text: text, style: TextStyle(color: baseColor))];
    
    final matches = query.toLowerCase().allMatches(text.toLowerCase());
    if (matches.isEmpty) return [TextSpan(text: text, style: TextStyle(color: baseColor))];
    
    int lastMatchEnd = 0;
    final List<TextSpan> spans = [];

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    int start = textLower.indexOf(queryLower, lastMatchEnd);
    final highlightBg = colorScheme.brightness == Brightness.light ? const Color(0xFFFEF08A) : const Color(0xFF854D0E);
    final highlightText = colorScheme.brightness == Brightness.light ? const Color(0xFF0F172A) : const Color(0xFFFEF08A);

    while (start != -1) {
      if (start != lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, start), style: TextStyle(color: baseColor)));
      }
      final end = start + queryLower.length;
      spans.add(TextSpan(
        text: text.substring(start, end),
        style: TextStyle(color: highlightText, backgroundColor: highlightBg),
      ));
      lastMatchEnd = end;
      start = textLower.indexOf(queryLower, lastMatchEnd);
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: TextStyle(color: baseColor)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isBlocked 
            ? (isDark ? colorScheme.surface.withValues(alpha: 0.5) : const Color(0xFFF8FAFC)) 
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: (isBlocked || isDark) ? [] : [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: isBlocked 
              ? colorScheme.onSurface.withValues(alpha: 0.1) 
              : (isDark ? colorScheme.onSurface.withValues(alpha: 0.05) : Colors.transparent),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isBlocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: _highlightSearchTerm(task.title, searchQuery, isBlocked, colorScheme),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                            color: isBlocked ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (task.id != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '#${task.id}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isBlocked ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildStatusBadge(colorScheme, isDark),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: isBlocked ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded, 
                      size: 16, 
                      color: isBlocked ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.5)
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.dueDate.toIso8601String().split('T')[0],
                      style: GoogleFonts.outfit(
                        fontSize: 13, 
                        fontWeight: FontWeight.w500,
                        color: isBlocked ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (isBlocked) 
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: isDark ? 0.2 : 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: colorScheme.error),
                          const SizedBox(width: 6),
                          Text(
                            'Blocked by #${task.blockedBy}',
                            style: GoogleFonts.outfit(
                              fontSize: 12, 
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme, bool isDark) {
    Color bgColor;
    Color textColor;
    String text;

    if (isBlocked) {
      bgColor = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF1F5F9);
      textColor = isDark ? colorScheme.onSurfaceVariant : const Color(0xFF94A3B8);
      text = 'BLOCKED';
    } else {
      switch (task.status) {
        case TaskStatus.inProgress:
          bgColor = isDark ? const Color(0xFF452E08) : const Color(0xFFFEF3C7);
          textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706);
          text = 'IN PROGRESS';
          break;
        case TaskStatus.done:
          bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
          textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);
          text = 'DONE';
          break;
        case TaskStatus.todo:
          bgColor = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);
          textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF4338CA);
          text = 'TO-DO';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
