import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _hasCompletedOnboardingKey = 'completed_onboarding';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userCreatedAtKey = 'user_created_at';
  static const _userNotificationsEnabledKey = 'user_notifications_enabled';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  String? get userName => _prefs.getString(_userNameKey);
  String? get userEmail => _prefs.getString(_userEmailKey);
  DateTime? get userCreatedAt {
    final timestamp = _prefs.getInt(_userCreatedAtKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  bool get notificationsEnabled =>
      _prefs.getBool(_userNotificationsEnabledKey) ?? true;

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  Future<void> setUserEmail(String? email) async {
    if (email != null) {
      await _prefs.setString(_userEmailKey, email);
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_hasCompletedOnboardingKey, completed);
    if (completed && userCreatedAt == null) {
      await _prefs.setInt(
          _userCreatedAtKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_userNotificationsEnabledKey, enabled);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return {
      'name': userName,
      'email': userEmail,
      'createdAt': userCreatedAt?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'onboardingCompleted': hasCompletedOnboarding,
    };
  }

  Future<void> clearUserProfile() async {
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userCreatedAtKey);
    await _prefs.remove(_hasCompletedOnboardingKey);
    await _prefs.remove(_userNotificationsEnabledKey);
  }
}
