import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';

class AuthRepository {
  final HttpClientApi _apiClient = HttpClientApi();

  Future<Response> login(Map<String, dynamic> body) async {
    return await _apiClient.client.post('/api/auth/login', data: body);
  }

  Future<Response> register(Map<String, dynamic> body) async {
    return await _apiClient.client.post('/api/auth/registers', data: body);
  }

  Future<Response> refreshToken(Map<String, dynamic> body) async {
    return await _apiClient.client.post('/api/auth/refresh-token', data: body);
  }

  Future<Response> forgotPassword(Map<String, dynamic> body) async {
    return await _apiClient.client.post('/api/auth/forgot-password', data: body);
  }

  Future<Response> resetPassword(Map<String, dynamic> body) async {
    return await _apiClient.client.post('/api/auth/reset-password', data: body);
  }
}
