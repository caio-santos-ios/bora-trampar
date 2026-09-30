import '../../api/http_client_api.dart';
import '../../models/transfer_model.dart';

class TransferRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<TransferModel>> get() async {
    final response = await _api.client.get('/api/transfers');
    return response.statusCode == 200
        ? (response.data["result"]["data"] as List)
              .map((e) => TransferModel.fromJson(e))
              .toList()
        : [];
  }

  Future<List<TransferModel>> getMyTransfers() async {
    final response = await _api.client.get('/api/transfers/me');
    return response.statusCode == 200
        ? (response.data["result"]["data"] as List)
              .map((e) => TransferModel.fromJson(e))
              .toList()
        : [];
  }

  Future<TransferModel?> create(Object data) async {
    final response = await _api.client.post('/api/transfers', data: data);
    final result = response.data?["result"];
    final map = result is Map && result["data"] != null ? result["data"] : result;
    return (response.statusCode == 200 || response.statusCode == 201) && map is Map
        ? TransferModel.fromJson(Map<String, dynamic>.from(map))
        : null;
  }

  Future<bool> updatePixKey(String pixKeyType, String pixKey) async {
    final response = await _api.client.put(
      '/api/profile-professionals/pix',
      data: {'pixKeyType': pixKeyType, 'pixKey': pixKey},
    );
    return response.statusCode == 200;
  }
}
