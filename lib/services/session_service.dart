import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _lastActiveKey = 'last_active_time';
  static const Duration sessionTimeout = Duration(minutes: 10);

  // Save current time whenever app goes background / inactive
  static Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastActiveKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Check whether session already expired
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt(_lastActiveKey);

    if (lastActiveMillis == null) {
      return false;
    }

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
    final now = DateTime.now();

    return now.difference(lastActive) > sessionTimeout;
  }

  // Clear saved last active time
  static Future<void> clearLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveKey);
  }
}