import '../../api/http_client_api.dart';
import '../../models/category_model.dart';

class CategoryRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<CategoryModel>> get() async {
    final response = await _api.client.get('/api/categories');
    return response.statusCode == 200 ? (response.data["result"]["data"] as List).map((e) => CategoryModel.fromJson(e)).toList() : [];
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.client.get('/api/categories/select');
    return response.statusCode == 200 ? (response.data["result"]["data"] as List).map((e) => CategoryModel.fromJson(e)).toList() : [];
  }
}
