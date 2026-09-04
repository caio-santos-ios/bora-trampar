class ProfileProfessionalModel {
  final String? id;
  final String userId;
  final String profession;
  final String bio;
  final int experienceYears;
  final bool isAvailableNow;
  final bool isProfileCompleted;
  final String identityDocumentType;
  final String identityDocumentNumber;
  final String identityDocumentFrontUrl;
  final String identityDocumentBackUrl;
  final String identitySelfieUrl;
  final String identityVerificationStatus;
  final String identityVerificationNotes;
  final ProfessionalAddressModel address;
  final List<ProfessionalServiceItemModel> services;
  final List<ProfessionalWorkingDayModel> workingHours;
  final List<String> portfolioPhotos;
  final double rating;
  final int reviewCount;
  final int completedServicesCount;
  final List<String> badges;

  ProfileProfessionalModel({
    this.id,
    required this.userId,
    required this.profession,
    required this.bio,
    this.experienceYears = 0,
    this.isAvailableNow = true,
    this.isProfileCompleted = false,
    this.identityDocumentType = 'CNH',
    this.identityDocumentNumber = '',
    this.identityDocumentFrontUrl = '',
    this.identityDocumentBackUrl = '',
    this.identitySelfieUrl = '',
    this.identityVerificationStatus = 'Pending',
    this.identityVerificationNotes = '',
    required this.address,
    this.services = const [],
    this.workingHours = const [],
    this.portfolioPhotos = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.completedServicesCount = 0,
    this.badges = const [],
  });

  factory ProfileProfessionalModel.fromJson(Map json) {
    final map = Map<String, dynamic>.from(json);
    return ProfileProfessionalModel(
      id: map['id']?.toString() ?? map['_id']?.toString(),
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      profession: map['profession']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      experienceYears: (map['experienceYears'] ?? map['experience_years'] as num?)?.toInt() ?? 0,
      isAvailableNow: map['isAvailableNow'] ?? map['is_available_now'] ?? true,
      isProfileCompleted: map['isProfileCompleted'] ?? map['is_profile_completed'] ?? false,
      identityDocumentType: map['identityDocumentType']?.toString() ?? map['identity_document_type']?.toString() ?? 'CNH',
      identityDocumentNumber: map['identityDocumentNumber']?.toString() ?? map['identity_document_number']?.toString() ?? '',
      identityDocumentFrontUrl: map['identityDocumentFrontUrl']?.toString() ?? map['identity_document_front_url']?.toString() ?? '',
      identityDocumentBackUrl: map['identityDocumentBackUrl']?.toString() ?? map['identity_document_back_url']?.toString() ?? '',
      identitySelfieUrl: map['identitySelfieUrl']?.toString() ?? map['identity_selfie_url']?.toString() ?? '',
      identityVerificationStatus: map['identityVerificationStatus']?.toString() ?? map['identity_verification_status']?.toString() ?? 'Pending',
      identityVerificationNotes: map['identityVerificationNotes']?.toString() ?? map['identity_verification_notes']?.toString() ?? map['reviewNotes']?.toString() ?? '',
      address: map['address'] is Map
          ? ProfessionalAddressModel.fromJson(map['address'] as Map)
          : ProfessionalAddressModel(),
      services: ((map['services'] ?? map['Services']) as List?)
              ?.map<ProfessionalServiceItemModel>((item) => ProfessionalServiceItemModel.fromJson(item is Map ? item : {}))
              .toList() ??
          <ProfessionalServiceItemModel>[],
      workingHours: ((map['workingHours'] ?? map['working_hours']) as List?)
              ?.map<ProfessionalWorkingDayModel>((item) => ProfessionalWorkingDayModel.fromJson(item is Map ? item : {}))
              .toList() ??
          <ProfessionalWorkingDayModel>[],
      portfolioPhotos: ((map['portfolioPhotos'] ?? map['portfolio_photos']) as List?)
              ?.map<String>((item) => item.toString())
              .toList() ??
          <String>[],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] ?? map['review_count'] as num?)?.toInt() ?? 0,
      completedServicesCount:
          (map['completedServicesCount'] ?? map['completed_services_count'] as num?)?.toInt() ?? 0,
      badges: (map['badges'] as List?)
              ?.map<String>((item) => item.toString())
              .toList() ??
          <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'profession': profession,
      'bio': bio,
      'experienceYears': experienceYears,
      'isAvailableNow': isAvailableNow,
      'isProfileCompleted': isProfileCompleted,
      'identityDocumentType': identityDocumentType,
      'identityDocumentNumber': identityDocumentNumber,
      'identityDocumentFrontUrl': identityDocumentFrontUrl,
      'identityDocumentBackUrl': identityDocumentBackUrl,
      'identitySelfieUrl': identitySelfieUrl,
      'identityVerificationStatus': identityVerificationStatus,
      'identityVerificationNotes': identityVerificationNotes,
      'address': address.toJson(),
      'services': services.map((s) => s.toJson()).toList(),
      'workingHours': workingHours.map((w) => w.toJson()).toList(),
      'portfolioPhotos': portfolioPhotos,
      'rating': rating,
      'reviewCount': reviewCount,
      'completedServicesCount': completedServicesCount,
      'badges': badges,
    };
  }
}

class ProfessionalAddressModel {
  final String zipCode;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final int serviceRadiusKm;

  ProfessionalAddressModel({
    this.zipCode = '',
    this.street = '',
    this.number = '',
    this.complement = '',
    this.neighborhood = '',
    this.city = '',
    this.state = 'SP',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.serviceRadiusKm = 25,
  });

  factory ProfessionalAddressModel.fromJson(Map json) {
    final map = Map<String, dynamic>.from(json);
    return ProfessionalAddressModel(
      zipCode: map['zipCode']?.toString() ?? map['zip_code']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      complement: map['complement']?.toString() ?? '',
      neighborhood: map['neighborhood']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? 'SP',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      serviceRadiusKm: (map['serviceRadiusKm'] ?? map['service_radius_km'] as num?)?.toInt() ?? 25,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zipCode': zipCode,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'serviceRadiusKm': serviceRadiusKm,
    };
  }
}

class ProfessionalServiceItemModel {
  final String categoryId;
  final String categoryName;
  final String serviceId;
  final String serviceName;
  final double price;
  final String priceType;
  final int estimatedMinutes;
  final String description;

  ProfessionalServiceItemModel({
    this.categoryId = '',
    this.categoryName = '',
    this.serviceId = '',
    this.serviceName = '',
    this.price = 0.0,
    this.priceType = 'Diária',
    this.estimatedMinutes = 480,
    this.description = '',
  });

  factory ProfessionalServiceItemModel.fromJson(Map json) {
    final map = Map<String, dynamic>.from(json);
    return ProfessionalServiceItemModel(
      categoryId: map['categoryId']?.toString() ?? map['category_id']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? map['category_name']?.toString() ?? '',
      serviceId: map['serviceId']?.toString() ?? map['service_id']?.toString() ?? '',
      serviceName: map['serviceName']?.toString() ?? map['service_name']?.toString() ?? '',
      price: () {
        final raw = map['price'] ?? map['Price'] ?? map['basePrice'] ?? map['base_price'] ?? map['valor'];
        if (raw is num) return raw.toDouble();
        if (raw != null) {
          final s = raw.toString().replaceAll(',', '.');
          final parsed = double.tryParse(s);
          if (parsed != null) return parsed;
        }
        return 0.0;
      }(),
      priceType: map['priceType']?.toString() ?? map['price_type']?.toString() ?? 'Diária',
      estimatedMinutes: (map['estimatedMinutes'] ?? map['estimated_minutes'] as num?)?.toInt() ?? 480,
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'priceType': priceType,
      'estimatedMinutes': estimatedMinutes,
      'description': description,
    };
  }
}

class ProfessionalWorkingDayModel {
  final int dayOfWeek;
  final String dayName;
  final bool isActive;
  final String startHour;
  final String endHour;
  final String breakStart;
  final String breakEnd;

  ProfessionalWorkingDayModel({
    required this.dayOfWeek,
    required this.dayName,
    this.isActive = true,
    this.startHour = '08:00',
    this.endHour = '18:00',
    this.breakStart = '12:00',
    this.breakEnd = '13:00',
  });

  factory ProfessionalWorkingDayModel.fromJson(Map json) {
    final map = Map<String, dynamic>.from(json);
    return ProfessionalWorkingDayModel(
      dayOfWeek: (map['dayOfWeek'] ?? map['day_of_week'] as num?)?.toInt() ?? 0,
      dayName: map['dayName']?.toString() ?? map['day_name']?.toString() ?? '',
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      startHour: map['startHour']?.toString() ?? map['start_hour']?.toString() ?? '08:00',
      endHour: map['endHour']?.toString() ?? map['end_hour']?.toString() ?? '18:00',
      breakStart: map['breakStart']?.toString() ?? map['break_start']?.toString() ?? '12:00',
      breakEnd: map['breakEnd']?.toString() ?? map['break_end']?.toString() ?? '13:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'isActive': isActive,
      'startHour': startHour,
      'endHour': endHour,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
    };
  }
}
