import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/task_form_viewmodel.dart';
import '../widgets/task_form_widget.dart';

class TaskFormScreen extends StatelessWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskFormViewModel(task: task),
      child: Consumer<TaskFormViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.isEditing ? 'Edit Task' : 'New Task'),
            ),
            body: TaskFormWidget(viewModel: viewModel),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _saveTask(context, viewModel),
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
          );
        },
      ),
    );
  }

  void _saveTask(BuildContext context, TaskFormViewModel viewModel) {
    final task = viewModel.createTask();
    if (task != null) {
      Navigator.pop(context, task);
    }
  }
}
