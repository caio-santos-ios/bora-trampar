import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';
import '../../models/category_model.dart';

class CategoryRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _api.client.get('/api/categories');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          return res.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
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
