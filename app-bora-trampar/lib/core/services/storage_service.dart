import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String boxName = 'boratrampar';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  static String getToken() {
    return _box.get('token', defaultValue: '') ?? '';
  }

  static Future<void> setToken(String token) async {
    await _box.put('token', token);
  }

  static String getRefreshToken() {
    return _box.get('refresh_token', defaultValue: '') ?? '';
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await _box.put('refresh_token', refreshToken);
  }

  static dynamic getUser() {
    return _box.get('user');
  }

  static Future<void> setUser(dynamic user) async {
    await _box.put('user', user);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
