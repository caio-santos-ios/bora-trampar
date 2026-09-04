import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';
import '../../models/dashboard_model.dart';

class DashboardRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<DashboardModel?> getMetrics({DateTime? startDate, DateTime? endDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _api.client.get(
        '/api/dashboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null && res['data'] is Map) {
          res = res['data'];
        }
        if (res is Map<String, dynamic>) {
          return DashboardModel.fromJson(res);
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
