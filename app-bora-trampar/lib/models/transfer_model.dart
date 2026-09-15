class TransferModel {
  final String id;
  final String userId;
  final double amount;
  final String pixKeyType;
  final String pixKey;
  final String status;
  final String notes;
  final DateTime? createdAt;

  const TransferModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.pixKeyType,
    required this.pixKey,
    required this.status,
    this.notes = '',
    this.createdAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
    } else if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString());
    }

    double parseAmount(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return TransferModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      amount: parseAmount(json['amount'] ?? json['value']),
      pixKeyType: (json['pixKeyType'] ?? json['pix_key_type'] ?? '').toString(),
      pixKey: (json['pixKey'] ?? json['pix_key'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'pixKeyType': pixKeyType,
      'pixKey': pixKey,
      'status': status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
      case 'SUCCESS':
        return 'Concluída';
      case 'CANCELLED':
      case 'FAILED':
      case 'REJECTED':
        return 'Cancelada';
      case 'PROCESSING':
        return 'Em Processamento';
      case 'PENDING':
      default:
        return 'Pendente';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
