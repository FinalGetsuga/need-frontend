import 'package:shared_preferences/shared_preferences.dart';

class RememberMeService {
  static const _rememberMeKey = 'remember_me';
  static const _emailKey = 'remembered_email';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveRememberMe({
    required bool rememberMe,
    required String email,
  }) async {
    try {
      final prefs = await _instance;

      await prefs.setBool(_rememberMeKey, rememberMe);

      if (rememberMe) {
        await prefs.setString(_emailKey, email);
      } else {
        await clearRememberMe();
      }
    } catch (e) {
      throw Exception('Failed to save remember me preference: $e');
    }
  }

  Future<bool> getRememberMe() async {
    try {
      final prefs = await _instance;
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      throw Exception('Failed to load remember me preference: $e');
    }
  }

  Future<String?> getRememberedEmail() async {
    try {
      final prefs = await _instance;
      return prefs.getString(_emailKey);
    } catch (e) {
      throw Exception('Failed to load remembered email: $e');
    }
  }

  Future<void> clearRememberMe() async {
    try {
      final prefs = await _instance;
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_emailKey);
    } catch (e) {
      throw Exception('Failed to clear remember me preference: $e');
    }
  }
}