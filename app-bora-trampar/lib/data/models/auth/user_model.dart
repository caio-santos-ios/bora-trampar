class UserModel {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? photo;
  final String? whatsapp;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photo,
    this.whatsapp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role']?.toString(),
      photo: json['photo']?.toString(),
      whatsapp: json['whatsapp'] ?? json['whatsApp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo': photo,
      'whatsapp': whatsapp,
    };
  }
}
