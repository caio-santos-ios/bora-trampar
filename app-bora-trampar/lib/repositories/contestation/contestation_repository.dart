import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';

class ContestationRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<bool> createContestation({
    required String appointmentId,
    required String reason,
    String description = '',
    String customerEvidenceUrl = '',
    List<String> photos = const [],
    String videoUrl = '',
  }) async {
    try {
      final response = await _api.client.post(
        '/api/contestations',
        data: {
          'appointmentId': appointmentId,
          'reason': reason,
          'description': description,
          'customerEvidenceUrl': customerEvidenceUrl.isNotEmpty
              ? customerEvidenceUrl
              : (photos.isNotEmpty ? photos.first : ''),
          'photos': photos,
          'videoUrl': videoUrl,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getContestationByAppointment(String appointmentId) async {
    try {
      final response = await _api.client.get('/api/contestations/appointment/$appointmentId');
      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['result'] ?? response.data['Result'] ?? response.data;
        if (result is Map<String, dynamic>) {
          return result;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateContestation({
    required String id,
    String? status,
    String? statusLabel,
    String description = '',
    List<String>? photos,
    String videoUrl = '',
  }) async {
    try {
      final Map<String, dynamic> body = {'id': id};
      if (status != null && status.isNotEmpty) body['status'] = status;
      if (statusLabel != null && statusLabel.isNotEmpty) body['statusLabel'] = statusLabel;
      if (description.isNotEmpty) body['description'] = description;
      if (photos != null && photos.isNotEmpty) {
        body['photos'] = photos;
        body['customerEvidenceUrl'] = photos.first;
      }
      if (videoUrl.isNotEmpty) body['videoUrl'] = videoUrl;

      final response = await _api.client.put('/api/contestations', data: body);
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
