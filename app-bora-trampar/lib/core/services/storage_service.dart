import 'package:app_bora_trampar/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String boxName = 'boratrampar';
  static const String environment = kReleaseMode ? 'prod': 'dev';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  static String getToken() {
    return _box.get('${environment}Token', defaultValue: '') ?? '';
  }

  static Future<void> setToken(String token) async {
    await _box.put('${environment}Token', token);
  }

  static String getRefreshToken() {
    return _box.get('${environment}Refresh_token', defaultValue: '') ?? '';
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await _box.put('${environment}Refresh_token', refreshToken);
  }

  static dynamic getUser() {
    return _box.get('${environment}User');
  }
  
  UserModel getCurrentUser() {
    final json = _box.get('${environment}User');
    return UserModel.fromJson(json);
  }

  static Future<void> setUser(dynamic user) async {
    await _box.put('${environment}User', user);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
