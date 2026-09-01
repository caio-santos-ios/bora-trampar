import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-indexed

  const AppStepper({
    super.key,
    this.totalSteps = 4,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepBefore = (index ~/ 2) + 1;
          final isCompleted = stepBefore < currentStep;
          return Container(
            width: 32,
            height: 2,
            color: isCompleted ? AppColors.primaryGold : AppColors.cardBorder,
          );
        }

        final stepNumber = (index ~/ 2) + 1;
        final isCompleted = stepNumber < currentStep;
        final isActive = stepNumber == currentStep;

        if (isCompleted) {
          return Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.textDark,
            ),
          );
        }

        if (isActive) {
          return Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.inter(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }

        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
