import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';
import '../services/export_service.dart';
import '../themes/theme_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../presentation/viewmodels/task_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Database
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);
  
  // Services
  getIt.registerSingleton<NotificationService>(
    NotificationService(),
  );
  getIt.registerSingleton<PreferencesService>(
    PreferencesService(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<ThemeService>(
    ThemeService(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<ExportService>(ExportService());
  
  // Repositories
  getIt.registerSingleton<TaskRepositoryImpl>(
    TaskRepositoryImpl(getIt<DatabaseHelper>()),
  );
  
  // ViewModels
  getIt.registerFactory(() => TaskViewModel());
}