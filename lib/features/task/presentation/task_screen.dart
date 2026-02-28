import 'package:assessment_flutter_interview/core/constants/enums.dart';
import 'package:assessment_flutter_interview/core/widgets/projects_card.dart';
import 'package:assessment_flutter_interview/features/projects/domain/project_data_model.dart';
import 'package:assessment_flutter_interview/features/projects/project_notifier.dart';
import 'package:assessment_flutter_interview/features/task/domain/task_data_model.dart';
import 'package:assessment_flutter_interview/features/task/task_notifier.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _ProjectsDashboardScreenState();
}

class _ProjectsDashboardScreenState extends ConsumerState<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Project Board',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          FilledButton.icon(
            onPressed: () => _showAddTaskBottomSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Task'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ref.watch(tasksProvider).when(
                data: (allTasks) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildKanbanRow(
                        context: context,
                        title: 'To Do',
                        stage: TaskType.todo,
                        color: Colors.blueGrey.shade50,
                        headerColor: Colors.blueGrey.shade800,
                        icon: Icons.list_alt_rounded,
                        allTasks: allTasks,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildKanbanRow(
                        context: context,
                        title: 'In Progress',
                        stage: TaskType.inProgress,
                        color: Colors.amber.shade50,
                        headerColor: Colors.amber.shade800,
                        icon: Icons.timelapse_rounded,
                        allTasks: allTasks,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildKanbanRow(
                        context: context,
                        title: 'Done',
                        stage: TaskType.done,
                        color: Colors.green.shade50,
                        headerColor: Colors.green.shade800,
                        icon: Icons.check_circle_outline_rounded,
                        allTasks: allTasks,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
        ),
      ),
    );
  }

  Widget _buildKanbanRow({
    required BuildContext context,
    required String title,
    required TaskType stage,
    required Color color,
    required Color headerColor,
    required IconData icon,
    required List<TaskDataModel> allTasks,
  }) {
    final rowTasks = allTasks.where((t) => t.stage == stage).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: headerColor.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: headerColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${rowTasks.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<TaskDataModel>(
              onWillAcceptWithDetails: (details) => details.data.stage != stage,
              onAcceptWithDetails: (details) => ref
                  .read(tasksProvider.notifier)
                  .updateTaskStage(details.data, stage),
              builder: (context, candidateData, rejectedData) {
                final isHovered = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? headerColor.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: rowTasks.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final task = rowTasks[index];
                      return SizedBox(
                        width: 300,
                        child: TaskCard(
                          task: task,
                          stageColor: headerColor,
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
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();

    // Retrieve projects list to render dropdown immediately inside the modal mapping
    final projects =
        ref.read(projectsProvider).valueOrNull ?? <ProjectDataModel>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? selectedProjectId =
            projects.isNotEmpty ? projects.first.id : null;
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Task',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(color: theme.colorScheme.primary),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(color: theme.colorScheme.primary),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (projects.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      decoration: InputDecoration(
                        labelText: 'Select Project',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: projects.map((ProjectDataModel project) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProjectId = newValue;
                        });
                      },
                    ),
                  if (projects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'No projects available. Please create a project first.',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: projects.isEmpty
                        ? null
                        : () {
                            final title = titleController.text.trim();
                            final desc = descController.text.trim();
                            if (title.isNotEmpty &&
                                desc.isNotEmpty &&
                                selectedProjectId != null) {
                              ref
                                  .read(tasksProvider.notifier)
                                  .addTask(title, desc, selectedProjectId!);
                              Navigator.pop(context);
                            }
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
