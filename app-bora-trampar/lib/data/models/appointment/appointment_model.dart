class AppointmentModel {
  final String id;
  final String profissionalId;
  final String customerId;
  final DateTime date;
  final String hour;
  final String? serviceName;
  final String? categoryName;
  final String? customerName;
  final String? professionalName;
  final String? address;
  final String? description;
  final String? notes;
  final List<String> photoUrls;
  final double? price;
  final String status;

  AppointmentModel({
    required this.id,
    required this.profissionalId,
    required this.customerId,
    required this.date,
    required this.hour,
    this.serviceName,
    this.categoryName,
    this.customerName,
    this.professionalName,
    this.address,
    this.description,
    this.notes,
    this.photoUrls = const [],
    this.price,
    this.status = 'PendingPayment',
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final rawPhotos = json['photo_urls'] ?? json['photoUrls'] ?? [];
    List<String> photosList = [];
    if (rawPhotos is List) {
      photosList = rawPhotos.map((p) => p.toString()).toList();
    }

    return AppointmentModel(
      id: json['id'] ?? json['_id'] ?? '',
      profissionalId: json['profissional_id'] ?? json['profissionalId'] ?? json['ProfissionalId'] ?? '',
      customerId: json['customer_id'] ?? json['customerId'] ?? json['CustomerId'] ?? '',
      date: parsedDate,
      hour: json['hour'] ?? json['Hour'] ?? '',
      serviceName: json['service_names'] ?? json['serviceName'] ?? json['service'] ?? json['Service'],
      categoryName: json['category_name'] ?? json['categoryName'] ?? json['CategoryName'],
      customerName: json['customerName'] ?? json['customer'] ?? json['Customer'],
      professionalName: json['professionalName'] ?? json['professional'] ?? json['Professional'],
      address: json['address'] ?? json['Address'],
      description: json['description'] ?? json['Description'],
      notes: json['notes'] ?? json['Notes'],
      photoUrls: photosList,
      price: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : (json['price'] != null ? (json['price'] as num).toDouble() : (json['value'] != null ? (json['value'] as num).toDouble() : null)),
      status: json['status'] ?? json['Status'] ?? 'PendingPayment',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profissional_id': profissionalId,
      'customer_id': customerId,
      'date': date.toIso8601String(),
      'hour': hour,
      'status': status,
      'service_names': serviceName,
      'category_name': categoryName,
      'address': address,
      'description': description,
      'notes': notes,
      'photo_urls': photoUrls,
      'total_price': price,
    };
  }
}
