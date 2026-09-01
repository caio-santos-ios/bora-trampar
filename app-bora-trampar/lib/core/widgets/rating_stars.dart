import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color starColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 16,
    this.starColor = AppColors.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return Icon(Icons.star_rounded, size: starSize, color: starColor);
        } else if (rating >= starValue - 0.5) {
          return Icon(Icons.star_half_rounded, size: starSize, color: starColor);
        } else {
          return Icon(Icons.star_outline_rounded, size: starSize, color: AppColors.textMuted);
        }
      }),
    );
  }
}
