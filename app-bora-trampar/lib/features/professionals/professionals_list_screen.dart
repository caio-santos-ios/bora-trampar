import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/professional_model.dart';
import 'professional_profile_screen.dart';

class ProfessionalsListScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const ProfessionalsListScreen({super.key, required this.orderRequest});

  @override
  State<ProfessionalsListScreen> createState() =>
      _ProfessionalsListScreenState();
}

class _ProfessionalsListScreenState extends State<ProfessionalsListScreen> {
  String _selectedSort = 'Mais bem avaliados';
  final List<String> _sortOptions = [
    'Mais bem avaliados',
    'Menor preço',
    'Mais rápidos (chegada)',
    'Mais experientes',
  ];

  List<ProfessionalModel> get _sortedProfessionals {
    final list = List<ProfessionalModel>.from(MockData.professionals);
    if (_selectedSort == 'Menor preço') {
      list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_selectedSort == 'Mais rápidos (chegada)') {
      list.sort((a, b) => a.arrivalTimeMinutes.compareTo(b.arrivalTimeMinutes));
    } else if (_selectedSort == 'Mais experientes') {
      list.sort((a, b) => b.completedServicesCount.compareTo(a.completedServicesCount));
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  void _onSelectProfessional(ProfessionalModel professional) {
    widget.orderRequest.selectedProfessional = professional;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfessionalProfileScreen(
          orderRequest: widget.orderRequest,
          professional: professional,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final locationText = widget.orderRequest.address.split('-').first.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sou cliente',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryGold,
              size: 18,
            ),
            label: Text(
              'Ajuda',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stepper bar (Step 5 active)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AppStepper(totalSteps: 5, currentStep: 5),
          ),

          // Scrollable List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Title + Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                              children: const [
                                TextSpan(text: 'Encontre os melhores\nprofissionais para o\n'),
                                TextSpan(
                                  text: 'seu serviço',
                                  style: TextStyle(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Compare perfis, avaliações e escolha quem você mais confia.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const BoraTrampaLogo(size: 34, showSubtitle: false, isHorizontal: false),
                  ],
                ),
                const SizedBox(height: 18),

                // Selected service chip card
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
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF1F1C12),
                        ),
                        child: const Icon(
                          Icons.foundation_rounded,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serviço solicitado',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              serviceName,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Ver detalhes',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryGold,
                                  fontSize: 11,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Alterar',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Location & Schedule Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryGold,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$locationText • Hoje, ${widget.orderRequest.scheduledTimeSlot}',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Editar',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section title + Sort dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profissionais disponíveis',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    PopupMenuButton<String>(
                      initialValue: _selectedSort,
                      onSelected: (val) => setState(() => _selectedSort = val),
                      color: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      itemBuilder: (context) {
                        return _sortOptions.map((opt) {
                          return PopupMenuItem(
                            value: opt,
                            child: Text(
                              opt,
                              style: GoogleFonts.inter(
                                color: opt == _selectedSort
                                    ? AppColors.primaryGold
                                    : AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Row(
                        children: [
                          Text(
                            'Ordenar por: ',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedSort,
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Professional Cards List
                ..._sortedProfessionals.map((prof) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildProfessionalCard(prof),
                  );
                }),
                const SizedBox(height: 10),

                // Bottom security guarantee banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          color: const Color(0xFF1E1A10),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pagamento seguro pelo app',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Você só paga após o serviço ser concluído.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryGold,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(ProfessionalModel prof) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Online dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2C2C2C),
                    backgroundImage: NetworkImage(prof.avatarUrl),
                  ),
                  if (prof.isAvailable)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBackground, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Verified Badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            prof.name,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (prof.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prof.role,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating & Services Count
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.primaryGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${prof.rating.toStringAsFixed(1)} (${prof.reviewCount} avaliações)',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prof.completedServicesCount} serviços realizados',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        prof.highlightBadge,
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price & Time column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'A partir de',
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'R\$ ${prof.basePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primaryGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Chega em até\n${prof.arrivalTimeMinutes} min',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => _onSelectProfessional(prof),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Ver perfil',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
