import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';
import '../../models/professional_model.dart';

class UserRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<ProfessionalModel>> getProfessionals() async {
    try {
      final response = await _api.client.get('/api/users');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          final users = res.map((u) => u as Map<String, dynamic>).toList();
          final List<ProfessionalModel> profList = users.where((u) {
            final role = (u['role'] ?? '').toString().toLowerCase();
            return role.contains('prof');
          }).map<ProfessionalModel>((u) {
            final name = u['name']?.toString() ?? '';
            final photo = u['photo']?.toString() ?? '';
            final rating = (u['rating'] as num?)?.toDouble() ?? 0.0;
            final reviewCount = (u['reviewCount'] as num?)?.toInt() ?? 0;
            final completedCount = (u['completedServicesCount'] as num?)?.toInt() ?? 0;
            final basePrice = (u['basePrice'] as num?)?.toDouble() ?? 0.0;
            final badge = u['badge']?.toString() ?? u['highlightBadge']?.toString() ?? '';
            final bio = u['bio']?.toString() ?? '';
            final city = u['city']?.toString() ?? '';
            final state = u['state']?.toString() ?? '';
            final region = [city, state].where((s) => s.isNotEmpty).join(', ');

            return ProfessionalModel(
              id: u['id']?.toString() ?? u['_id']?.toString() ?? '',
              name: name.isNotEmpty ? name : 'Profissional',
              role: u['profession']?.toString() ?? u['role']?.toString() ?? '',
              rating: rating,
              reviewCount: reviewCount,
              completedServicesCount: completedCount,
              arrivalTimeMinutes: (u['arrivalTimeMinutes'] as num?)?.toInt() ?? 0,
              basePrice: basePrice,
              highlightBadge: badge,
              avatarUrl: photo,
              bio: bio,
              offeredServices: const [],
              reviews: const [],
              region: region,
            );
          }).toList();

          return profList;
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
