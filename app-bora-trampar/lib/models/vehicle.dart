class Vehicle {
  final String id;
  final String professionalId;
  final String vehicleType;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final double approximateCapacityKg;
  final String dimensions;
  final String photoUrl;
  final String documentUrl;
  final bool isDefault;
  final bool isActive;
  final String approvalStatus;
  final String approvalNotes;
  final DateTime? createdAt;

  const Vehicle({
    this.id = '',
    this.professionalId = '',
    this.vehicleType = '',
    this.brand = '',
    this.model = '',
    this.year = 0,
    this.plateNumber = '',
    this.approximateCapacityKg = 0.0,
    this.dimensions = '',
    this.photoUrl = '',
    this.documentUrl = '',
    this.isDefault = false,
    this.isActive = true,
    this.approvalStatus = 'Pending',
    this.approvalNotes = '',
    this.createdAt,
  });

  String get approvalStatusLabel {
    switch (approvalStatus.toLowerCase()) {
      case 'approved':
      case 'approve':
        return 'Aprovado';
      case 'rejected':
      case 'reject':
        return 'Reprovado';
      case 'pending':
        return 'Em análise';
      default:
        return approvalStatus;
    }
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      professionalId: (json['professionalId'] ?? json['professional_id'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? json['vehicle_type'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      year: (json['year'] as num?)?.toInt() ?? 0,
      plateNumber: (json['plateNumber'] ?? json['plate_number'] ?? '').toString(),
      approximateCapacityKg:
          (json['approximateCapacityKg'] ?? json['approximate_capacity_kg'] as num?)?.toDouble() ?? 0.0,
      dimensions: (json['dimensions'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? json['photo_url'] ?? '').toString(),
      documentUrl: (json['documentUrl'] ?? json['document_url'] ?? '').toString(),
      isDefault: (json['isDefault'] ?? json['is_default'] ?? false) as bool,
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
      approvalStatus: (json['approvalStatus'] ?? json['approval_status'] ?? 'Pending').toString(),
      approvalNotes: (json['approvalNotes'] ?? json['approval_notes'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'vehicleType': vehicleType,
      'brand': brand,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
      'approximateCapacityKg': approximateCapacityKg,
      'dimensions': dimensions,
      'photoUrl': photoUrl,
      'documentUrl': documentUrl,
      'isDefault': isDefault,
    };
  }

  Vehicle copyWith({
    String? vehicleType,
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    double? approximateCapacityKg,
    String? dimensions,
    String? photoUrl,
    String? documentUrl,
    bool? isDefault,
  }) {
    return Vehicle(
      id: id,
      professionalId: professionalId,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      approximateCapacityKg: approximateCapacityKg ?? this.approximateCapacityKg,
      dimensions: dimensions ?? this.dimensions,
      photoUrl: photoUrl ?? this.photoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive,
      approvalStatus: approvalStatus,
      approvalNotes: approvalNotes,
      createdAt: createdAt,
    );
  }
}