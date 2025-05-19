import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidytask/core/services/notification_service.dart';
import 'package:tidytask/core/services/preferences_service.dart';
import 'package:tidytask/core/themes/theme_service.dart';
import 'package:tidytask/presentation/screens/onboarding_screen.dart';
import 'package:tidytask/presentation/screens/home_screen.dart';
import 'package:tidytask/presentation/viewmodels/task_viewmodel.dart';
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
    final prefsService = getIt<PreferencesService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<TaskViewModel>(),
        ),
      ],
      child: ListenableBuilder(
        listenable: themeService,
        builder: (context, _) {
          return MaterialApp(
            title: 'TidyTask',
            themeMode: themeService.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: prefsService.userName != null 
                ? const HomeScreen() 
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
