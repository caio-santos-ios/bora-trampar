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
}
