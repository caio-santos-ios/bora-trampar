import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';
import '../../models/profile/profile_professional_model.dart';

class ProfileProfessionalRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<ProfileProfessionalModel?> getMe() async {
    try {
      final response = await _api.client.get('/api/profile-professionals/me');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is Map) {
          return ProfileProfessionalModel.fromJson(Map<String, dynamic>.from(res));
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ProfileProfessionalModel?> getByUserId(String userId) async {
    try {
      final response = await _api.client.get('/api/profile-professionals/user/$userId');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is Map) {
          return ProfileProfessionalModel.fromJson(Map<String, dynamic>.from(res));
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<ProfileProfessionalModel>> getAllProfiles() async {
    try {
      final response = await _api.client.get('/api/profile-professionals');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          return res
              .map((item) => ProfileProfessionalModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<ProfileProfessionalModel?> saveProfile(ProfileProfessionalModel profile) async {
    try {
      final response = await _api.client.post(
        '/api/profile-professionals',
        data: profile.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is Map) {
          return ProfileProfessionalModel.fromJson(Map<String, dynamic>.from(res));
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      final response = await _api.client.patch(
        '/api/profile-professionals/availability',
        data: {'isAvailable': isAvailable},
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveIdentityVerification({
    required String documentType,
    required String documentNumber,
    required String frontUrl,
    required String backUrl,
    required String selfieUrl,
  }) async {
    try {
      final response = await _api.client.post(
        '/api/profile-professionals/identity',
        data: {
          'documentType': documentType,
          'documentNumber': documentNumber,
          'frontUrl': frontUrl,
          'backUrl': backUrl,
          'selfieUrl': selfieUrl,
        },
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
