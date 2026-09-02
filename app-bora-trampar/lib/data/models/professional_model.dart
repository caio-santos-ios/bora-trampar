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
    this.isVerified = false,
    this.isAvailable = true,
    required this.rating,
    required this.reviewCount,
    required this.completedServicesCount,
    required this.highlightBadge,
    required this.basePrice,
    required this.arrivalTimeMinutes,
    this.sinceYear = 0,
    this.responseTime = '',
    this.completionRate = '',
    required this.bio,
    required this.offeredServices,
    required this.reviews,
    this.region = '',
  });
}
