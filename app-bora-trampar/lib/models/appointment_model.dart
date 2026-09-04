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
      final rawDate = json['date'] ?? json['Date'];
      if (rawDate is DateTime) {
        parsedDate = rawDate;
      } else if (rawDate is Map) {
        final dVal = rawDate[r'$date'] ?? rawDate['date'];
        if (dVal is Map && dVal[r'$numberLong'] != null) {
          final millis = int.tryParse(dVal[r'$numberLong'].toString());
          parsedDate = millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : DateTime.now();
        } else {
          parsedDate = DateTime.tryParse(dVal?.toString() ?? '') ?? DateTime.now();
        }
      } else if (rawDate != null) {
        parsedDate = DateTime.parse(rawDate.toString());
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final rawPhotos = json['photo_urls'] ?? json['photoUrls'] ?? [];
    List<String> photosList = [];
    if (rawPhotos is List) {
      photosList = rawPhotos.map((p) => p.toString()).toList();
    }

    String parseString(dynamic val) {
      if (val == null) return '';
      if (val is String) return val;
      if (val is Map) {
        return val[r'$oid']?.toString() ?? val['id']?.toString() ?? val['_id']?.toString() ?? val.toString();
      }
      return val.toString();
    }

    double? parsePrice(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val.replaceAll(',', '.'));
      if (val is Map) {
        final inner = val[r'$numberDecimal'] ?? val['numberDecimal'] ?? val['value'] ?? val['amount'];
        if (inner != null) {
          if (inner is num) return inner.toDouble();
          return double.tryParse(inner.toString().replaceAll(',', '.'));
        }
      }
      return null;
    }

    final rawPrice = json['total_price'] ?? json['totalPrice'] ?? json['price'] ?? json['value'];

    return AppointmentModel(
      id: parseString(json['id'] ?? json['_id']),
      profissionalId: parseString(json['profissional_id'] ?? json['profissionalId'] ?? json['ProfissionalId']),
      customerId: parseString(json['customer_id'] ?? json['customerId'] ?? json['CustomerId']),
      date: parsedDate,
      hour: json['hour']?.toString() ?? json['Hour']?.toString() ?? '',
      serviceName: json['service_names']?.toString() ?? json['serviceName']?.toString() ?? json['service']?.toString() ?? json['Service']?.toString(),
      categoryName: json['category_name']?.toString() ?? json['categoryName']?.toString() ?? json['CategoryName']?.toString(),
      customerName: json['customerName']?.toString() ?? json['customer']?.toString() ?? json['Customer']?.toString(),
      professionalName: json['professionalName']?.toString() ?? json['professional']?.toString() ?? json['Professional']?.toString(),
      address: json['address']?.toString() ?? json['Address']?.toString(),
      description: json['description']?.toString() ?? json['Description']?.toString(),
      notes: json['notes']?.toString() ?? json['Notes']?.toString(),
      photoUrls: photosList,
      price: parsePrice(rawPrice),
      status: json['status']?.toString() ?? json['Status']?.toString() ?? 'PendingPayment',
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
