import 'profile_professional_model.dart';
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
  final List<ProfessionalServiceItemModel> servicesList;
  final List<ReviewModel> reviews;
  final String region;
  final double? distanceKm;
  final List<dynamic>? workingHours;
  final Map<String, dynamic>? address;

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
    this.servicesList = const [],
    required this.reviews,
    this.region = '',
    this.distanceKm,
    this.workingHours,
    this.address,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['offeredServices'] ?? json['services'];
    List<String> serviceNames = [];
    List<ProfessionalServiceItemModel> servicesList = [];

    if (rawServices is List) {
      for (final s in rawServices) {
        if (s is String) {
          serviceNames.add(s);
        } else if (s is Map) {
          final sName = s['serviceName'] ?? s['service_name'] ?? s['name'];
          if (sName != null) serviceNames.add(sName.toString());

          servicesList.add(ProfessionalServiceItemModel.fromJson(s));
        }
      }
    }

    final rawBasePrice = json['basePrice'] ?? json['base_price'] ?? json['price'] ?? json['Price'];
    double basePrice = 0.0;
    if (rawBasePrice is num && rawBasePrice > 0) {
      basePrice = rawBasePrice.toDouble();
    } else if (rawBasePrice != null && rawBasePrice is! Map) {
      final parsed = double.tryParse(rawBasePrice.toString().replaceAll(',', '.'));
      if (parsed != null && parsed > 0) basePrice = parsed;
    }

    if (basePrice <= 0.0) {
      for (final s in servicesList) {
        if (s.price > 0) {
          basePrice = s.price;
          break;
        }
      }
    }

    if (serviceNames.isEmpty && json['profession'] != null && json['profession'].toString().isNotEmpty) {
      serviceNames.add(json['profession'].toString());
    }

    String region = json['region']?.toString() ?? '';
    Map<String, dynamic>? addressMap;
    if (json['address'] is Map) {
      addressMap = Map<String, dynamic>.from(json['address'] as Map);
      if (region.isEmpty) {
        final city = addressMap['city']?.toString() ?? '';
        final state = addressMap['state']?.toString() ?? '';
        final neighborhood = addressMap['neighborhood']?.toString() ?? '';
        if (city.isNotEmpty && state.isNotEmpty) {
          region = '$city - $state';
        } else if (city.isNotEmpty) {
          region = city;
        } else if (neighborhood.isNotEmpty) {
          region = neighborhood;
        }
      }
    }

    final rawDist = json['distanciaKm'] ?? json['distanceKm'] ?? json['distance_km'];
    final double? distanceKm = rawDist is num
        ? rawDist.toDouble()
        : (rawDist != null ? double.tryParse(rawDist.toString()) : null);

    final reviewCount = (json['reviewCount'] ?? json['review_count'] as num?)?.toInt() ?? 0;
    final completedCount = (json['completedServicesCount'] ?? json['completed_services_count'] as num?)?.toInt() ?? 0;

    return ProfessionalModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Profissional',
      role: json['profession']?.toString() ?? json['role']?.toString() ?? 'Profissional',
      avatarUrl: json['avatarUrl']?.toString() ?? json['photo']?.toString() ?? json['photoUrl']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      isAvailable: json['isAvailable'] == null ? true : json['isAvailable'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: reviewCount,
      completedServicesCount: completedCount,
      highlightBadge: json['highlightBadge']?.toString() ?? json['badge']?.toString() ?? '',
      basePrice: basePrice > 0 ? basePrice : 150.0,
      arrivalTimeMinutes: (json['arrivalTimeMinutes'] as num?)?.toInt() ?? 30,
      sinceYear: (json['sinceYear'] as num?)?.toInt() ?? DateTime.now().year,
      responseTime: json['responseTime']?.toString() ?? 'Em até 1 hora',
      completionRate: json['completionRate']?.toString() ?? '100%',
      bio: json['bio']?.toString() ?? '',
      offeredServices: serviceNames,
      servicesList: servicesList,
      reviews: const [],
      region: region,
      distanceKm: distanceKm,
      workingHours: json['working_hours'] is List ? json['working_hours'] as List : (json['workingHours'] is List ? json['workingHours'] as List : null),
      address: addressMap,
    );
  }

  ProfessionalModel copyWith({
    String? id,
    String? name,
    String? role,
    String? avatarUrl,
    bool? isVerified,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    int? completedServicesCount,
    String? highlightBadge,
    double? basePrice,
    int? arrivalTimeMinutes,
    int? sinceYear,
    String? responseTime,
    String? completionRate,
    String? bio,
    List<String>? offeredServices,
    List<ProfessionalServiceItemModel>? servicesList,
    List<ReviewModel>? reviews,
    String? region,
    double? distanceKm,
    List<dynamic>? workingHours,
    Map<String, dynamic>? address,
  }) {
    return ProfessionalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedServicesCount: completedServicesCount ?? this.completedServicesCount,
      highlightBadge: highlightBadge ?? this.highlightBadge,
      basePrice: basePrice ?? this.basePrice,
      arrivalTimeMinutes: arrivalTimeMinutes ?? this.arrivalTimeMinutes,
      sinceYear: sinceYear ?? this.sinceYear,
      responseTime: responseTime ?? this.responseTime,
      completionRate: completionRate ?? this.completionRate,
      bio: bio ?? this.bio,
      offeredServices: offeredServices ?? this.offeredServices,
      servicesList: servicesList ?? this.servicesList,
      reviews: reviews ?? this.reviews,
      region: region ?? this.region,
      distanceKm: distanceKm ?? this.distanceKm,
      workingHours: workingHours ?? this.workingHours,
      address: address ?? this.address,
    );
  }
}
