import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/task.dart';

class ExportService {
  Future<String> exportTasksToCSV(List<Task> tasks) async {
    final csvData = [
      // Header
      [
        'ID',
        'Title',
        'Description',
        'Created At',
        'Deadline',
        'Priority',
        'Status',
        'Tags'
      ],
      // Data
      ...tasks.map((task) => [
            task.id,
            task.title,
            task.description ?? '',
            task.createdAt.toIso8601String(),
            task.deadline?.toIso8601String() ?? '',
            task.priority.toString(),
            task.isCompleted ? 'Completed' : 'Pending',
            task.tags.join(', '),
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_export.csv');

    await file.writeAsString(csvString);
    return file.path;
  }
}
