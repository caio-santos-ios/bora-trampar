class FreightOrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String professionalId;
  final String professionalName;
  final String originAddress;
  final String destinationAddress;
  final String description;
  final String vehicleType;
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
    this.originAddress = '',
    this.destinationAddress = '',
    this.description = '',
    this.vehicleType = '',
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
    return FreightOrderModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      customerName: (json['customerName'] ?? json['customer_name'] ?? '').toString(),
      professionalId: (json['professionalId'] ?? json['professional_id'] ?? '').toString(),
      professionalName: (json['professionalName'] ?? json['professional_name'] ?? '').toString(),
      originAddress: (json['originAddress'] ?? json['origin_address'] ?? '').toString(),
      destinationAddress: (json['destinationAddress'] ?? json['destination_address'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? json['vehicle_type'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'Pending').toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'description': description,
      'vehicleType': vehicleType,
      'price': price,
      'status': status,
      'notes': notes,
    };
  }
}
