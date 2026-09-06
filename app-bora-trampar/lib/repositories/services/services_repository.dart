import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';
import '../../models/service_item_model.dart';

class ServicesRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<ServiceItemModel>> getServices({String? categoryId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _api.client.get(
        '/api/services',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          final allServices = res.map((item) {
            final json = item as Map<String, dynamic>;
            return ServiceItemModel(
              id: (json['id'] ?? json['_id'] ?? '').toString(),
              categoryId: (json['categoryId'] ?? json['category_id'] ?? '').toString(),
              name: (json['name'] ?? json['title'] ?? 'Serviço').toString(),
              basePrice: (json['basePrice'] ?? json['price'] ?? 150.0).toDouble(),
            );
          }).toList();

          if (categoryId != null && categoryId.isNotEmpty) {
            return allServices
                .where((s) =>
                    s.categoryId.trim().toLowerCase() ==
                    categoryId.trim().toLowerCase())
                .toList();
          }
          return allServices;
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }
}
