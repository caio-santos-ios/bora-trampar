import 'review_model.dart';

class ProfessionalModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isVerified;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int completedServicesCount;
  final String highlightBadge;
  final double basePrice;
  final int arrivalTimeMinutes;
  final int sinceYear;
  final String responseTime;
  final String completionRate;
  final String bio;
  final List<String> offeredServices;
  final List<ReviewModel> reviews;
  final String region;

  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.isVerified = true,
    this.isAvailable = true,
    required this.rating,
    required this.reviewCount,
    required this.completedServicesCount,
    required this.highlightBadge,
    required this.basePrice,
    required this.arrivalTimeMinutes,
    this.sinceYear = 2018,
    this.responseTime = 'Geralmente em 15 minutos',
    this.completionRate = '98% dos serviços concluídos',
    required this.bio,
    required this.offeredServices,
    required this.reviews,
    this.region = 'Moema e região',
  });
}
