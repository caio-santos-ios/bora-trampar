import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:app_bora_trampar/core/services/storage_service.dart';

class HttpClientApi {
  static const String _prodUrl = 'https://bora-trampar.onrender.com';
  static const String _devUrl = 'http://192.168.18.72:5067';

  static String get baseUrl {
    const customUrl = String.fromEnvironment('BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    return kReleaseMode ? _prodUrl : _devUrl;
  }

  final Dio _dio = Dio();

  HttpClientApi() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 90);
    _dio.options.receiveTimeout = const Duration(seconds: 90);
    _dio.options.sendTimeout = const Duration(seconds: 90);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String token = StorageService.getToken();
          if (token.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('auth_token') ?? '';
          }

          if (token.isNotEmpty) {
            if (options.path.contains('/auth/refresh-token')) {
              String refreshToken = StorageService.getRefreshToken();
              if (refreshToken.isEmpty) {
                final prefs = await SharedPreferences.getInstance();
                refreshToken = prefs.getString('refresh_token') ?? '';
              }
              options.headers['Authorization'] = 'Bearer $refreshToken';
            } else {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          if (options.data is! FormData) {
            options.headers['Content-Type'] = 'application/json';
          }
          options.headers['Accept'] = 'application/json';

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}
