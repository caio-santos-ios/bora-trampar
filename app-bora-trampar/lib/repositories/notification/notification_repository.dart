import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';
import '../../models/notification_model.dart';

class NotificationRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _api.client.get('/api/notifications');
      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is List) {
          return res.map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _api.client.patch('/api/notifications/$id/read');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateFcmToken(String token) async {
    try {
      final response = await _api.client.post(
        '/api/users/fcm-token',
        data: {'token': token},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
