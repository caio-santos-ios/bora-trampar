import '../../api/http_client_api.dart';
import '../../models/freight_order_model.dart';

class FreightOrderRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<FreightOrderModel>> get({String? query}) async {
    final endpoint = query != null && query.isNotEmpty
        ? '/api/freight-orders?$query'
        : '/api/freight-orders';
    final response = await _api.client.get(endpoint);
    return response.statusCode == 200 && response.data["result"]?["data"] != null
        ? (response.data["result"]["data"] as List)
            .map((e) => FreightOrderModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  Future<List<FreightOrderModel>> getMyOrdersAsCustomer() async {
    final response = await _api.client.get('/api/freight-orders/customer');
    return response.statusCode == 200 && response.data["result"] != null
        ? (response.data["result"] as List)
            .map((e) => FreightOrderModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  Future<List<FreightOrderModel>> getMyOrdersAsProfessional() async {
    final response = await _api.client.get('/api/freight-orders/professional');
    return response.statusCode == 200 && response.data["result"] != null
        ? (response.data["result"] as List)
            .map((e) => FreightOrderModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  Future<FreightOrderModel?> getById(String id) async {
    final response = await _api.client.get('/api/freight-orders/$id');
    return response.statusCode == 200 && response.data["result"] != null
        ? FreightOrderModel.fromJson(Map<String, dynamic>.from(response.data["result"]))
        : null;
  }

  Future<bool> create(Map<String, dynamic> data) async {
    final response = await _api.client.post('/api/freight-orders', data: data);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> update(Map<String, dynamic> data) async {
    final response = await _api.client.put('/api/freight-orders', data: data);
    return response.statusCode == 200;
  }

  Future<bool> accept(String id) async {
    final response = await _api.client.put('/api/freight-orders/$id/accept');
    return response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final response = await _api.client.delete('/api/freight-orders/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
