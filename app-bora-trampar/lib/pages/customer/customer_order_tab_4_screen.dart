import 'package:app_bora_trampar/pages/professional/professional_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../models/order_request_model.dart';
import '../../models/professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';

class CustomerOrderTab4Screen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const CustomerOrderTab4Screen({super.key, required this.orderRequest});

  @override
  State<CustomerOrderTab4Screen> createState() =>
      _CustomerOrderTab4ScreenState();
}

class _CustomerOrderTab4ScreenState extends State<CustomerOrderTab4Screen> {
  final _profileRepository = ProfileProfessionalRepository();

  List<ProfessionalModel> _professionals = [];
  Map<String, double> _proDistances = {};
  bool _isLoading = true;
  String _selectedSort = 'Mais bem avaliados';
  final List<String> _sortOptions = [
    'Mais bem avaliados',
    'Mais próximos',
    'Menor preço',
    'Mais rápidos (chegada)',
    'Mais experientes',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    try {
      setState(() => _isLoading = true);

      String timeStr = widget.orderRequest.scheduledTimeSlot.trim();
      final match = RegExp(r'\d{1,2}:\d{2}').firstMatch(timeStr);
      if (match != null) {
        timeStr = match.group(0)!;
      }

      final serviceIds = widget.orderRequest.selectedServices
          .map((s) => s.id)
          .where((id) => id.isNotEmpty)
          .join(';');

      final rawList = await _profileRepository.getProfessionalsAvailabilityRaw(
        widget.orderRequest.scheduledDate ?? DateTime.now(),
        timeStr,
        widget.orderRequest.customerLatitude,
        widget.orderRequest.customerLongitude,
        serviceIds: serviceIds.isNotEmpty ? serviceIds : null,
      );

      final List<ProfessionalModel> loadedPros = [];
      final Map<String, double> distances = {};

      for (final item in rawList) {
        final prof = ProfessionalModel.fromJson(item);
        loadedPros.add(prof);
        final dist = prof.distanceKm ?? (item['distanciaKm'] as num?)?.toDouble() ?? 0.0;
        distances[prof.id] = dist;
      }

      if (mounted) {
        setState(() {
          _professionals = loadedPros;
          _proDistances = distances;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _professionals = [];
          _proDistances = {};
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ProfessionalModel> get _sortedProfessionals {
    final list = List<ProfessionalModel>.from(_professionals);

    if (_selectedSort == 'Mais próximos') {
      list.sort((a, b) {
        final distA = a.distanceKm ?? _proDistances[a.id] ?? 999999.0;
        final distB = b.distanceKm ?? _proDistances[b.id] ?? 999999.0;
        return distA.compareTo(distB);
      });
    } else if (_selectedSort == 'Menor preço') {
      list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_selectedSort == 'Mais rápidos (chegada)') {
      list.sort((a, b) => a.arrivalTimeMinutes.compareTo(b.arrivalTimeMinutes));
    } else if (_selectedSort == 'Mais experientes') {
      list.sort(
        (a, b) => b.completedServicesCount.compareTo(a.completedServicesCount),
      );
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  void _onSelectProfessional(ProfessionalModel professional) {
    double effectivePrice = professional.basePrice;
    if (effectivePrice <= 0.0 && professional.servicesList.isNotEmpty) {
      final matching = professional.servicesList.firstWhere(
        (s) => widget.orderRequest.selectedServices.any(
          (sel) => sel.id == s.serviceId || sel.name.toLowerCase() == s.serviceName.toLowerCase(),
        ),
        orElse: () => professional.servicesList.firstWhere(
          (s) => s.price > 0,
          orElse: () => professional.servicesList.first,
        ),
      );
      if (matching.price > 0) {
        effectivePrice = matching.price;
      }
    }

    if (effectivePrice <= 0.0 &&
        widget.orderRequest.selectedServices.isNotEmpty &&
        widget.orderRequest.selectedServices.first.basePrice > 0) {
      effectivePrice = widget.orderRequest.selectedServices.first.basePrice;
    }

    if (effectivePrice <= 0.0) {
      effectivePrice = 150.0;
    }

    final resolvedProf = professional.copyWith(
      basePrice: effectivePrice,
    );

    widget.orderRequest.selectedProfessional = resolvedProf;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfessionalProfileScreen(
          orderRequest: widget.orderRequest,
          professional: resolvedProf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final locationText = widget.orderRequest.address.isNotEmpty
        ? widget.orderRequest.address.split('-').first.trim()
        : 'São Paulo, SP';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Central de Ajuda Bora Trampar',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            },
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
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AppStepper(totalSteps: 4, currentStep: 4),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      children: [
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
                                        TextSpan(
                                          text:
                                              'Encontre os melhores\nprofissionais para o\n',
                                        ),
                                        TextSpan(
                                          text: 'seu serviço',
                                          style: TextStyle(
                                            color: AppColors.primaryGold,
                                          ),
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
                            const BoraTrampaLogo(
                              size: 34,
                              showSubtitle: false,
                              isHorizontal: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
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
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryGold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                                  '$locationText • ${widget.orderRequest.scheduledTimeSlot}',
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
                        if (_sortedProfessionals.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.location_off_outlined,
                                  size: 44,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum profissional disponível',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Não encontramos profissionais que atendem no seu endereço ou tenham horário livre para esta data e horário.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.edit_calendar_outlined,
                                    size: 16,
                                    color: AppColors.primaryGold,
                                  ),
                                  label: Text(
                                    'Alterar data, horário ou local',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryGold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primaryGold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Profissionais disponíveis',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: _selectedSort,
                                onSelected: (val) =>
                                    setState(() => _selectedSort = val),
                                color: AppColors.cardBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.cardBorder,
                                  ),
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sort_rounded,
                                        color: AppColors.primaryGold,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 130,
                                        ),
                                        child: Text(
                                          _selectedSort,
                                          style: GoogleFonts.inter(
                                            color: AppColors.primaryGold,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primaryGold,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          for (final prof in _sortedProfessionals)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildProfessionalCard(prof),
                            ),
                        ],
                        const SizedBox(height: 10),
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
                                  border: Border.all(
                                    color: AppColors.primaryGold,
                                    width: 1.5,
                                  ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
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
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardElevated,
                    ),
                    child: ClipOval(
                      child: prof.avatarUrl.isNotEmpty
                          ? Image.network(
                              prof.avatarUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'P',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'P',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryGold,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
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
                          border: Border.all(
                            color: AppColors.cardBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (prof.isVerified &&
                            prof.highlightBadge.isNotEmpty) ...[
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
                    if (prof.reviewCount > 0)
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
                      )
                    else
                      Text(
                        'Novo profissional na plataforma',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (prof.completedServicesCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${prof.completedServicesCount} serviços realizados',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    Builder(
                      builder: (context) {
                        final dist = prof.distanceKm ?? _proDistances[prof.id];
                        if (dist != null && dist > 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.near_me_outlined,
                                  size: 12,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${dist.toStringAsFixed(1)} km de você',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (prof.region.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    prof.region,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Horário disponível',
                          style: GoogleFonts.inter(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (prof.highlightBadge.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                  ],
                ),
              ),
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
                  Builder(
                    builder: (context) {
                      double cardPrice = prof.basePrice;
                      if (cardPrice <= 0.0 && prof.servicesList.isNotEmpty) {
                        final matching = prof.servicesList.firstWhere(
                          (s) => widget.orderRequest.selectedServices.any(
                            (sel) => sel.id == s.serviceId || sel.name.toLowerCase() == s.serviceName.toLowerCase(),
                          ),
                          orElse: () => prof.servicesList.firstWhere((s) => s.price > 0, orElse: () => prof.servicesList.first),
                        );
                        if (matching.price > 0) cardPrice = matching.price;
                      }
                      if (cardPrice <= 0.0 &&
                          widget.orderRequest.selectedServices.isNotEmpty &&
                          widget.orderRequest.selectedServices.first.basePrice > 0) {
                        cardPrice = widget.orderRequest.selectedServices.first.basePrice;
                      }
                      if (cardPrice <= 0.0) cardPrice = 150.0;

                      return Text(
                        'R\$ ${cardPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
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
