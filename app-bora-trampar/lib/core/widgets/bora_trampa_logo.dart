import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BoraTrampaLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final bool isHorizontal;

  const BoraTrampaLogo({
    super.key,
    this.size = 48,
    this.showSubtitle = true,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo-bora-trampar.jpeg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.engineering_rounded,
              color: AppColors.primaryGold,
              size: size * 0.58,
            ),
          ),
        ),
      ),
    );

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isHorizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bora',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Trampa',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGold,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 2),
          Text(
            'PROFISSIONAIS POR DIÁRIA',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: (size * 0.16).clamp(8.0, 11.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 12),
          textWidget,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(height: 10),
        textWidget,
      ],
    );
  }
}
