import 'package:assessment_flutter_interview/features/task/domain/task_data_model.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final TaskDataModel task;
  final Color stageColor;
  final bool isDragging;

  const TaskCard({
    super.key,
    required this.task,
    required this.stageColor,
    this.isDragging = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isBeingDragged = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use isDragging to check if this is the floating feedback card,
    // and _isBeingDragged to check if this is the original card being held.
    final isActiveDraggingPhase = widget.isDragging || _isBeingDragged;

    final card = Container(
      // Keep exactly 300 width to stabilize the feedback widget size and alignment
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (widget.isDragging)
            BoxShadow(
              color: widget.stageColor.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
        border: Border.all(
          color: isActiveDraggingPhase
              ? widget.stageColor
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: isActiveDraggingPhase ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.isDragging)
                Icon(Icons.drag_indicator,
                    color: Colors.grey.shade400, size: 20)
              else
                Draggable<TaskDataModel>(
                  data: widget.task,
                  onDragStarted: () => setState(() => _isBeingDragged = true),
                  onDragEnd: (_) => setState(() => _isBeingDragged = false),
                  onDraggableCanceled: (_, __) =>
                      setState(() => _isBeingDragged = false),
                  // Offset the feedback so it snaps perfectly where the finger touches the handle
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform.translate(
                      offset: const Offset(-268, -12),
                      child: Transform.rotate(
                        angle: 0.03, // Slight tilt for flair
                        child: TaskCard(
                          task: widget.task,
                          stageColor: widget.stageColor,
                          isDragging: true,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    // Make the anchor icon invisible since the whole card will jump to 40% opacity
                    opacity: 0.0,
                    child: Icon(Icons.drag_indicator,
                        color: Colors.grey.shade400, size: 20),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Icon(Icons.drag_indicator,
                        color: Colors.grey.shade400, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            widget.task.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          if (widget.isDragging) const SizedBox(height: 16) else const Spacer(),
          Row(
            children: [
              // Mock Avatars
              SizedBox(
                width: 56,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Text('JD',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      left: 18,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.pink.shade100,
                        child: Text('AM',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.pink.shade900,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.stageColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PRI-0${widget.task.id}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.stageColor,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );

    return _isBeingDragged ? Opacity(opacity: 0.4, child: card) : card;
  }
}
