class DailyWordModel {
  final String id;
  final String title;
  final String verse;
  final String reference;
  final String message;
  final String targetAudience;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  DailyWordModel({
    required this.id,
    required this.title,
    required this.verse,
    required this.reference,
    required this.message,
    required this.targetAudience,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory DailyWordModel.fromJson(Map<String, dynamic> json) {
    return DailyWordModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'PALAVRA DO DIA',
      verse: json['verse']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      targetAudience: (json['target_audience'] ?? json['targetAudience'])?.toString() ?? 'both',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      startDate: json['start_date'] != null || json['startDate'] != null
          ? DateTime.tryParse((json['start_date'] ?? json['startDate']).toString())
          : null,
      endDate: json['end_date'] != null || json['endDate'] != null
          ? DateTime.tryParse((json['end_date'] ?? json['endDate']).toString())
          : null,
    );
  }
}
