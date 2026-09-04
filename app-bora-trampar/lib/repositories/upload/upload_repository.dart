import 'dart:io';
import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';

class UploadRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<String?> uploadImage(File file, {String folder = 'documents'}) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'folder': folder,
      });

      final response = await _api.client.post('/api/uploads/image', data: formData);

      if (response.statusCode == 200 && response.data != null) {
        return response.data['url']?.toString();
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadBase64(String base64, {String folder = 'documents'}) async {
    try {
      final response = await _api.client.post(
        '/api/uploads/base64',
        data: {
          'base64': base64,
          'folder': folder,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['url']?.toString();
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
