import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidytask/core/services/export_service.dart';
import 'package:tidytask/core/services/preferences_service.dart';
import 'package:tidytask/core/themes/theme_service.dart';
import 'package:tidytask/domain/entities/task.dart';
import '../../core/di/service_locator.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/task_card.dart';
import '../screens/task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<TaskViewModel>()..loadTasks(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hi, ${getIt<PreferencesService>().userName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.dark_mode),
              onPressed: () => getIt<ThemeService>().toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _handleExport(context),
            ),
          ],
        ),
        body: Consumer<TaskViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(child: Text(viewModel.error!));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.tasks.length,
              itemBuilder: (context, index) {
                final task = viewModel.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () => _editTask(context, task, viewModel),
                  onComplete: () => viewModel.updateTask(
                    task.copyWith(isCompleted: !task.isCompleted),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createTask(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _createTask(BuildContext context) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => const TaskFormScreen(),
      ),
    );

    if (result != null && context.mounted) {
      final viewModel = context.read<TaskViewModel>();
      await viewModel.createTask(result);
    }
  }

  Future<void> _editTask(
      BuildContext context, Task task, TaskViewModel viewModel) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );

    if (result != null && context.mounted) {
      await viewModel.updateTask(result);
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    final exportService = getIt<ExportService>();
    final viewModel = context.read<TaskViewModel>();

    try {
      final filePath = await exportService.exportTasksToCSV(viewModel.tasks);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tasks exported to: $filePath'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export tasks: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
