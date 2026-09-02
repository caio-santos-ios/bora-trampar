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
            final name = u['name']?.toString() ?? 'Profissional';
            final photo = u['photo']?.toString() ?? '';
            final rating = (u['rating'] as num?)?.toDouble() ?? 0.0;
            final reviewCount = (u['reviewCount'] as num?)?.toInt() ?? 0;
            final completedCount = (u['completedServicesCount'] as num?)?.toInt() ?? 0;
            final basePrice = (u['basePrice'] as num?)?.toDouble() ?? 200.0;
            final badge = u['badge']?.toString() ?? (reviewCount > 10 ? 'Verificado' : '');
            final bio = u['bio']?.toString() ?? 'Profissional autônomo na plataforma Bora Trampar.';
            final city = u['city']?.toString();
            final state = u['state']?.toString() ?? 'SP';
            final region = city != null ? '$city, $state' : 'São Paulo, SP';

            return ProfessionalModel(
              id: u['id']?.toString() ?? u['_id']?.toString() ?? '',
              name: name,
              role: u['profession']?.toString() ?? 'Profissional Autônomo',
              rating: rating,
              reviewCount: reviewCount,
              completedServicesCount: completedCount,
              arrivalTimeMinutes: 30,
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
