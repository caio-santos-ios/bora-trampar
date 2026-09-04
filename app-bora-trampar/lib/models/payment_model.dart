class PaymentModel {
  final String id;
  final String methodPayment;
  final DateTime date;
  final double value;
  final String? title;
  final String? partyName;
  final String? status;

  PaymentModel({
    required this.id,
    required this.methodPayment,
    required this.date,
    required this.value,
    this.title,
    this.partyName,
    this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return PaymentModel(
      id: json['id'] ?? json['_id'] ?? '',
      methodPayment: json['method_payment'] ?? json['methodPayment'] ?? json['MethodPayment'] ?? 'PIX Instantâneo',
      date: parsedDate,
      value: (json['value'] ?? json['Value'] ?? 0).toDouble(),
      title: json['title'] ?? json['Title'] ?? 'Diária de Serviço',
      partyName: json['partyName'] ?? json['PartyName'],
      status: json['status'] ?? json['Status'] ?? 'Aprovado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method_payment': methodPayment,
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
