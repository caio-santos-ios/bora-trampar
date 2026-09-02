class DashboardModel {
  final double totalRevenue;
  final int monthAppointments;
  final int activePros;
  final int pendingVerifications;
  final int openDisputes;
  final double satisfactionRate;
  final List<RevenueHistoryItemModel> revenueHistory;
  final List<CategoryDistributionItemModel> categoryDistribution;
  final List<RecentAppointmentItemModel> recentAppointments;

  DashboardModel({
    required this.totalRevenue,
    required this.monthAppointments,
    required this.activePros,
    required this.pendingVerifications,
    required this.openDisputes,
    required this.satisfactionRate,
    required this.revenueHistory,
    required this.categoryDistribution,
    required this.recentAppointments,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRevenue: (json['totalRevenue'] ?? json['TotalRevenue'] ?? 0).toDouble(),
      monthAppointments: json['monthAppointments'] ?? json['MonthAppointments'] ?? 0,
      activePros: json['activePros'] ?? json['ActivePros'] ?? 0,
      pendingVerifications: json['pendingVerifications'] ?? json['PendingVerifications'] ?? 0,
      openDisputes: json['openDisputes'] ?? json['OpenDisputes'] ?? 0,
      satisfactionRate: (json['satisfactionRate'] ?? json['SatisfactionRate'] ?? 100.0).toDouble(),
      revenueHistory: (json['revenueHistory'] ?? json['RevenueHistory'] as List? ?? [])
          .map((item) => RevenueHistoryItemModel.fromJson(item))
          .toList(),
      categoryDistribution: (json['categoryDistribution'] ?? json['CategoryDistribution'] as List? ?? [])
          .map((item) => CategoryDistributionItemModel.fromJson(item))
          .toList(),
      recentAppointments: (json['recentAppointments'] ?? json['RecentAppointments'] as List? ?? [])
          .map((item) => RecentAppointmentItemModel.fromJson(item))
          .toList(),
    );
  }
}

class RevenueHistoryItemModel {
  final String label;
  final double revenue;

  RevenueHistoryItemModel({required this.label, required this.revenue});

  factory RevenueHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueHistoryItemModel(
      label: json['label'] ?? json['Label'] ?? '',
      revenue: (json['revenue'] ?? json['Revenue'] ?? 0).toDouble(),
    );
  }
}

class CategoryDistributionItemModel {
  final String name;
  final int count;

  CategoryDistributionItemModel({required this.name, required this.count});

  factory CategoryDistributionItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryDistributionItemModel(
      name: json['name'] ?? json['Name'] ?? '',
      count: json['count'] ?? json['Count'] ?? 0,
    );
  }
}

class RecentAppointmentItemModel {
  final String id;
  final String customer;
  final String professional;
  final String service;
  final String date;
  final double value;
  final String status;
  final String statusText;

  RecentAppointmentItemModel({
    required this.id,
    required this.customer,
    required this.professional,
    required this.service,
    required this.date,
    required this.value,
    required this.status,
    required this.statusText,
  });

  factory RecentAppointmentItemModel.fromJson(Map<String, dynamic> json) {
    return RecentAppointmentItemModel(
      id: json['id'] ?? json['Id'] ?? '',
      customer: json['customer'] ?? json['Customer'] ?? '',
      professional: json['professional'] ?? json['Professional'] ?? '',
      service: json['service'] ?? json['Service'] ?? '',
      date: json['date'] ?? json['Date'] ?? '',
      value: (json['value'] ?? json['Value'] ?? 0).toDouble(),
      status: json['status'] ?? json['Status'] ?? 'confirmed',
      statusText: json['statusText'] ?? json['StatusText'] ?? 'Confirmado',
    );
  }
}
