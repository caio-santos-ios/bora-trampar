import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final String token = prefs.getString('auth_token') ?? '';

          if (token.isNotEmpty) {
            if (options.path.contains('/auth/refresh-token')) {
              final String refreshToken = prefs.getString('refresh_token') ?? '';
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
