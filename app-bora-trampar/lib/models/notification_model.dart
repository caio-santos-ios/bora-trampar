class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? subtitle;
  final String? appointmentId;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.subtitle,
    this.appointmentId,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'General',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['services']?.toString(),
      appointmentId: json['appointmentId']?.toString() ?? json['appointment_id']?.toString(),
      read: json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'subtitle': subtitle,
      'appointmentId': appointmentId,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
