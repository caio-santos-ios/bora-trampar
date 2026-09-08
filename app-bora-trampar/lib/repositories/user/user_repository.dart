import '../../api/http_client_api.dart';
import '../../models/user_model.dart';
import '../../models/professional_model.dart';

class UserRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<ProfessionalModel>> getProfessionals() async {
    
    return [];
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _api.client.get('/api/users/me');
      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map) {
          return UserModel.fromJson(Map<String, dynamic>.from(res));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> creditWallet(double amount, {String reason = ''}) async {
    try {
      final response = await _api.client.post(
        '/api/users/wallet/credit',
        data: {'amount': amount, 'reason': reason},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePhoto(String userId, String photoUrl) async {
    try {
      final response = await _api.client.put(
        '/api/users',
        data: {
          'id': userId,
          'photo': photoUrl,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser({
    required String id,
    String? name,
    String? email,
    String? whatsapp,
  }) async {
    try {
      final response = await _api.client.put(
        '/api/users',
        data: {
          'id': id,
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (whatsapp != null) 'whatsApp': whatsapp,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    try {
      final response = await _api.client.delete('/api/users/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
