import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/rating_stars.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/professional_model.dart';
import '../order_confirmation/order_confirmation_screen.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final OrderRequestModel orderRequest;
  final ProfessionalModel professional;

  const ProfessionalProfileScreen({
    super.key,
    required this.orderRequest,
    required this.professional,
  });

  void _onRequestProfessional(BuildContext context) {
    orderRequest.selectedProfessional = professional;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(orderRequest: orderRequest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Perfil do profissional',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link de compartilhamento copiado!'),
                  backgroundColor: AppColors.cardElevated,
                ),
              );
            },
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.primaryGold,
              size: 16,
            ),
            label: Text(
              'Compartilhar',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Hero Profile Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Image with Online Badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            professional.avatarUrl,
                            width: 100,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 110,
                              color: AppColors.cardElevated,
                              child: const Icon(Icons.person, size: 50, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        if (professional.isAvailable)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Disponível',
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  professional.name,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (professional.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.primaryGold,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.foundation_rounded,
                                color: AppColors.primaryGold,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                professional.role,
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primaryGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${professional.rating.toStringAsFixed(1)} (${professional.reviewCount} avaliações)',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_turned_in_outlined,
                                color: AppColors.textMuted,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${professional.completedServicesCount} serviços realizados',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1A10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: AppColors.primaryGold),
                                const SizedBox(width: 4),
                                Text(
                                  'Profissional ${professional.highlightBadge.toLowerCase()}',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick stats row (3 cards)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      // Stat 1: Desde 2018
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: AppColors.primaryGold, size: 18),
                            const SizedBox(height: 6),
                            Text(
                              'Desde ${professional.sinceYear}',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'No BoraTrampa',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      // Stat 2: Tempo de resposta
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppColors.primaryGold, size: 18),
                            const SizedBox(height: 6),
                            Text(
                              'Tempo de resposta',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              professional.responseTime,
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      // Stat 3: Taxa de conclusão
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.thumb_up_alt_outlined, color: AppColors.primaryGold, size: 18),
                            const SizedBox(height: 6),
                            Text(
                              'Taxa de conclusão',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '98% concluídos',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sobre o profissional
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Sobre o profissional',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  professional.bio,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Serviços oferecidos
                Row(
                  children: [
                    const Icon(Icons.handyman_outlined, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Serviços oferecidos',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: professional.offeredServices.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            service,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Avaliações Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_outline_rounded, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Avaliações',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text(
                            'Ver todas (${professional.reviewCount})',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Reviews List
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big rating box
                    Column(
                      children: [
                        Text(
                          professional.rating.toStringAsFixed(1).replaceAll('.', ','),
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        RatingStars(rating: professional.rating, starSize: 14),
                        const SizedBox(height: 4),
                        Text(
                          '${professional.reviewCount} avaliações',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Review list items
                    Expanded(
                      child: Column(
                        children: professional.reviews.map((rev) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Color(0xFF333333),
                                        child: Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(width: 8),
                                      RatingStars(rating: rev.rating, starSize: 12),
                                      const Spacer(),
                                      Text(
                                        rev.timeAgo,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    rev.comment,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Valor card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          color: const Color(0xFF1E1A10),
                        ),
                        child: const Center(
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'A partir de R\$ ${professional.basePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'O valor final pode variar conforme o serviço.',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Atendimento
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primaryGold, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Atendimento',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              professional.region,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Disponibilidade
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disponibilidade',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Disponível para o horário selecionado.',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Voltar Button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back_rounded, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Voltar',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Solicitar Profissional Button
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _onRequestProfessional(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Solicitar profissional',
                        style: GoogleFonts.inter(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
