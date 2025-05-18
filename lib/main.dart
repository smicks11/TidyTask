import 'package:flutter/material.dart';
import 'package:tidytask/core/services/notification_service.dart';
import 'package:tidytask/core/themes/theme_service.dart';
import 'core/di/service_locator.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupServiceLocator();
  await getIt<NotificationService>().initialize();

  runApp(const TidyTaskApp());
}

class TidyTaskApp extends StatelessWidget {
  const TidyTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = getIt<ThemeService>();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'TidyTask',
          themeMode: themeService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        );
      },
    );
  }
}
