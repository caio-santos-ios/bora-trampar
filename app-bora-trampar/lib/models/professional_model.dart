import 'review_model.dart';

class ProfessionalModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isVerified;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int completedServicesCount;
  final String highlightBadge;
  final double basePrice;
  final int arrivalTimeMinutes;
  final int sinceYear;
  final String responseTime;
  final String completionRate;
  final String bio;
  final List<String> offeredServices;
  final List<ReviewModel> reviews;
  final String region;

  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.isVerified = false,
    this.isAvailable = true,
    required this.rating,
    required this.reviewCount,
    required this.completedServicesCount,
    required this.highlightBadge,
    required this.basePrice,
    required this.arrivalTimeMinutes,
    this.sinceYear = 0,
    this.responseTime = '',
    this.completionRate = '',
    required this.bio,
    required this.offeredServices,
    required this.reviews,
    this.region = '',
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final rawBasePrice = json['basePrice'] ?? json['base_price'] ?? json['price'] ?? json['Price'];
    final basePrice = rawBasePrice is num
        ? rawBasePrice.toDouble()
        : (rawBasePrice != null ? double.tryParse(rawBasePrice.toString().replaceAll(',', '.')) ?? 0.0 : 0.0);

    final rawServices = json['offeredServices'] ?? json['services'];
    List<String> serviceNames = [];
    if (rawServices is List) {
      for (final s in rawServices) {
        if (s is String) {
          serviceNames.add(s);
        } else if (s is Map) {
          final sName = s['serviceName'] ?? s['service_name'] ?? s['name'];
          if (sName != null) serviceNames.add(sName.toString());
        }
      }
    }
    if (serviceNames.isEmpty && json['profession'] != null && json['profession'].toString().isNotEmpty) {
      serviceNames.add(json['profession'].toString());
    }

    return ProfessionalModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Profissional',
      role: json['profession']?.toString() ?? json['role']?.toString() ?? 'Profissional',
      avatarUrl: json['avatarUrl']?.toString() ?? json['photo']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      isAvailable: json['isAvailable'] == null ? true : json['isAvailable'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      completedServicesCount: (json['completedServicesCount'] as num?)?.toInt() ?? 0,
      highlightBadge: json['highlightBadge']?.toString() ?? json['badge']?.toString() ?? '',
      basePrice: basePrice > 0 ? basePrice : 150.0,
      arrivalTimeMinutes: (json['arrivalTimeMinutes'] as num?)?.toInt() ?? 30,
      sinceYear: (json['sinceYear'] as num?)?.toInt() ?? DateTime.now().year,
      responseTime: json['responseTime']?.toString() ?? 'Em até 1 hora',
      completionRate: json['completionRate']?.toString() ?? '100%',
      bio: json['bio']?.toString() ?? '',
      offeredServices: serviceNames,
      reviews: const [],
      region: json['region']?.toString() ?? '',
    );
  }
}
