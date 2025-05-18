import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../viewmodels/task_form_viewmodel.dart';

class TaskFormWidget extends StatelessWidget {
  final TaskFormViewModel viewModel;

  const TaskFormWidget({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildPrioritySelector(),
          const SizedBox(height: 16),
          _buildDeadlineSelector(context),
          const SizedBox(height: 16),
          _buildTagInput(),
          if (viewModel.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildTagList(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      initialValue: viewModel.title,
      decoration: InputDecoration(
        labelText: 'Title',
        border: const OutlineInputBorder(),
        errorText: viewModel.error,
      ),
      onChanged: viewModel.setTitle,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      initialValue: viewModel.description,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: viewModel.setDescription,
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<TaskPriority>(
      value: viewModel.priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: TaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) viewModel.setPriority(value);
      },
    );
  }

  Widget _buildDeadlineSelector(BuildContext context) {
    return ListTile(
      title: const Text('Deadline'),
      subtitle: Text(
        viewModel.deadline != null
            ? '${viewModel.deadline!.day}/${viewModel.deadline!.month}/${viewModel.deadline!.year}'
            : 'No deadline set',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDeadline(context),
          ),
          if (viewModel.deadline != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => viewModel.setDeadline(null),
            ),
        ],
      ),
    );
  }

  Widget _buildTagInput() {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Add Tag',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) {
              viewModel.addTag(value);
              controller.clear();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            viewModel.addTag(controller.text);
            controller.clear();
          },
        ),
      ],
    );
  }

  Widget _buildTagList() {
    return Wrap(
      spacing: 8,
      children: viewModel.tags
          .map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => viewModel.removeTag(tag),
              ))
          .toList(),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: viewModel.deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      viewModel.setDeadline(date);
    }
  }
}
