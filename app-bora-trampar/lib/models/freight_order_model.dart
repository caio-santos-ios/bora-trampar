import 'package:app_bora_trampar/repositories/address/address_repository.dart';

class FreightAddress {
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  /// Endereço formatado para exibição
  String get display {
    final parts = <String>[];
    if (street.isNotEmpty) {
      parts.add(number.isNotEmpty ? '$street, $number' : street);
    }
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (city.isNotEmpty) {
      parts.add(state.isNotEmpty ? '$city - $state' : city);
    }
    return parts.join(', ');
  }

  String get shortDisplay {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(', ');
  }

  @override
  String toString() => display.isNotEmpty ? display : street;

  const FreightAddress({
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.latitude,
    this.longitude,
  });

  factory FreightAddress.fromJson(Map<String, dynamic> json) {
    return FreightAddress(
      street: (json['street'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      neighborhood: (json['neighborhood'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      zipCode: (json['zipCode'] ?? json['zip_code'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Cria a partir de um AddressSuggestion (retorno da busca de endereços)
  factory FreightAddress.fromSuggestion(AddressSuggestion s) {
    return FreightAddress(
      street: s.title,
      city: s.city ?? '',
      state: s.state ?? '',
      latitude: s.latitude,
      longitude: s.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class FreightOrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String professionalId;
  final String professionalName;
  final String vehicleId;
  final FreightAddress originAddress;
  final FreightAddress destinationAddress;
  final String cargoType;
  final double cargoWeight;
  final double distanceKm;
  final String durationLabel;
  final DateTime? scheduledDate;
  final String vehicleType;
  final String description;
  final double price;
  final String status;
  final String notes;
  final DateTime? createdAt;

  const FreightOrderModel({
    required this.id,
    this.customerId = '',
    this.customerName = '',
    this.professionalId = '',
    this.professionalName = '',
    this.vehicleId = '',
    this.originAddress = const FreightAddress(),
    this.destinationAddress = const FreightAddress(),
    this.cargoType = '',
    this.cargoWeight = 0.0,
    this.distanceKm = 0.0,
    this.durationLabel = '',
    this.scheduledDate,
    this.vehicleType = '',
    this.description = '',
    this.price = 0.0,
    this.status = 'Pending',
    this.notes = '',
    this.createdAt,
  });

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'accepted':
        return 'Aceito';
      case 'inprogress':
      case 'in_progress':
        return 'Em Transporte';
      case 'finished':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  factory FreightOrderModel.fromJson(Map<String, dynamic> json) {
    FreightAddress parseAddress(dynamic raw) {
      if (raw == null) return const FreightAddress();
      if (raw is Map) {
        return FreightAddress.fromJson(Map<String, dynamic>.from(raw));
      }
      // fallback: raw é string antiga
      return FreightAddress(street: raw.toString());
    }

    return FreightOrderModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      customerName:
          (json['customerName'] ?? json['customer_name'] ?? '').toString(),
      professionalId:
          (json['professionalId'] ?? json['professional_id'] ?? '').toString(),
      professionalName:
          (json['professionalName'] ?? json['professional_name'] ?? '')
              .toString(),
      vehicleId: (json['vehicleId'] ?? json['vehicle_id'] ?? '').toString(),
      originAddress:
          parseAddress(json['originAddress'] ?? json['origin_address']),
      destinationAddress:
          parseAddress(json['destinationAddress'] ?? json['destination_address']),
      cargoType: (json['cargoType'] ?? json['cargo_type'] ?? '').toString(),
      cargoWeight: (json['cargoWeight'] ?? json['cargo_weight'] as num?)
              ?.toDouble() ??
          0.0,
      distanceKm:
          (json['distanceKm'] ?? json['distance_km'] as num?)?.toDouble() ??
              0.0,
      durationLabel:
          (json['durationLabel'] ?? json['duration_label'] ?? '').toString(),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'].toString())
          : (json['scheduled_date'] != null
              ? DateTime.tryParse(json['scheduled_date'].toString())
              : null),
      vehicleType:
          (json['vehicleType'] ?? json['vehicle_type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'Pending').toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'professionalId': professionalId,
        'professionalName': professionalName,
        'vehicleId': vehicleId,
        'originAddress': originAddress.toJson(),
        'destinationAddress': destinationAddress.toJson(),
        'cargoType': cargoType,
        'cargoWeight': cargoWeight,
        'distanceKm': distanceKm,
        'durationLabel': durationLabel,
        'scheduledDate': scheduledDate?.toIso8601String(),
        'vehicleType': vehicleType,
        'description': description,
        'price': price,
        'status': status,
        'notes': notes,
      };

  /// Calcula o preço estimado de frete com base na distância e peso
  static double calculatePrice({
    required double distanceKm,
    required double cargoWeightKg,
    double baseRate = 10.0,
    double ratePerKm = 2.5,
    double ratePerKg = 0.5,
  }) {
    return baseRate + (distanceKm * ratePerKm) + (cargoWeightKg * ratePerKg);
  }
}
