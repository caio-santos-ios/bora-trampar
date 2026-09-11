import '../../api/http_client_api.dart';
import '../../models/notification_model.dart';

class NotificationRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<AppNotification>> getNotifications(String userId) async {
    final response = await _api.client.get('/api/notifications?=user_id=$userId');
    return response.statusCode == 200 ? (response.data['result']['data'] as List).map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))).toList() : [];
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
