import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String _userIdKey = 'logged_in_user_id';
  static const String _lastActivityKey = 'last_activity';
  static const String _biometricUserIdKey = 'biometric_user_id';

  //simpan UserId setelah login 
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

//baca userId 
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  //catat waktu terakhir 
  Future<void> saveLastActivity() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _lastActivityKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  //baca waktu aktivitas terakhir 
  Future<DateTime?> getLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastActivityKey);

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  //hapus session ketika logout 
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_lastActivityKey);
  }

  //biometric 
  Future<void> saveBiometricUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_biometricUserIdKey, userId);
}

Future<int?> getBiometricUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_biometricUserIdKey);
}

Future<void> clearBiometricUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_biometricUserIdKey);
}
}
