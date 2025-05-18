import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize timezone
    tz.initializeTimeZones();

    await _notifications.initialize(settings);
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.deadline == null) return;

    final now = DateTime.now();
    if (task.deadline!.isBefore(now)) return;

    // Schedule 1 hour before deadline
    final scheduledDate = task.deadline!.subtract(const Duration(hours: 1));
    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      'The task "${task.title}" is due in 1 hour',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task deadlines',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelTaskReminder(Task task) async {
    await _notifications.cancel(task.id.hashCode);
  }
}
