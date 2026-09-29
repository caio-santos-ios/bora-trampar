import '../../api/http_client_api.dart';
import '../../models/vehicle.dart';

class VehicleRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<Vehicle>> getMyVehicles() async {
    final response = await _api.client.get('/api/vehicles/professional');
    return response.statusCode == 200 &&
            response.data["result"]?["data"] != null
        ? (response.data["result"]["data"] as List)
              .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : [];
  }

  Future<Vehicle?> getById(String id) async {
    final response = await _api.client.get('/api/vehicles/$id');
    return response.statusCode == 200 &&
            response.data["result"]?["data"] != null
        ? Vehicle.fromJson(
            Map<String, dynamic>.from(response.data["result"]["data"]),
          )
        : null;
  }

  Future<Vehicle?> create(Map<String, dynamic> data) async {
    final response = await _api.client.post('/api/vehicles', data: data);
    return (response.statusCode == 200 || response.statusCode == 201) &&
            response.data["result"]?["data"] != null
        ? Vehicle.fromJson(
            Map<String, dynamic>.from(response.data["result"]["data"]),
          )
        : null;
  }

  Future<Vehicle?> update(Map<String, dynamic> data) async {
    final response = await _api.client.put('/api/vehicles', data: data);
    return response.statusCode == 200 &&
            response.data["result"]?["data"] != null
        ? Vehicle.fromJson(
            Map<String, dynamic>.from(response.data["result"]["data"]),
          )
        : null;
  }

  Future<bool> setDefault(String id) async {
    final response = await _api.client.put('/api/vehicles/$id/set-default');
    return response.statusCode == 200;
  }

  Future<bool> delete(String id) async {
    final response = await _api.client.delete('/api/vehicles/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
