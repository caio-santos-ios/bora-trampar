import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../models/daily_word_model.dart';

class DailyWordCard extends StatelessWidget {
  final DailyWordModel dailyWord;

  const DailyWordCard({
    super.key,
    required this.dailyWord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 150,
              child: Image.asset(
                'assets/images/palavra-dia.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/palavra-dia.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F0F0F),
                      const Color(0xFF0F0F0F).withValues(alpha: 0.88),
                      Colors.transparent,
                    ],
                    stops: const [0.55, 0.78, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF16140F),
                          border: Border.all(
                            color: AppColors.primaryGold,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🙏 ${dailyWord.title.toUpperCase()}',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '“${dailyWord.verse}”',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dailyWord.reference,
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (dailyWord.message.trim().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.12),
                        thickness: 0.8,
                        height: 1,
                      ),
                    ),

                    _buildFormattedMessage(dailyWord.message.trim()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedMessage(String message) {
    final lines = message.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lines.first,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            lines.sublist(1).join('\n'),
            style: GoogleFonts.inter(
              color: AppColors.primaryGold,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      );
    }

    return Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
    );
  }
}
