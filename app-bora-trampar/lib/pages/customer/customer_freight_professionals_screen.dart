import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/util_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/toastfy_widget.dart';
import '../../models/freight_order_model.dart';
import '../../models/professional_model.dart';
import '../../repositories/freight_order/freight_order_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';

class CustomerFreightProfessionalsScreen extends StatefulWidget {
  final FreightOrderModel order;

  const CustomerFreightProfessionalsScreen({super.key, required this.order});

  @override
  State<CustomerFreightProfessionalsScreen> createState() =>
      _CustomerFreightProfessionalsScreenState();
}

class _CustomerFreightProfessionalsScreenState
    extends State<CustomerFreightProfessionalsScreen> {
  final _profileRepo = ProfileProfessionalRepository();
  final _freightRepo = FreightOrderRepository();

  List<ProfessionalModel> _professionals = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _selectedProfessionalId;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);
    try {
      // Busca profissionais com isFreight = true via query param
      final all = await _profileRepo.getProfessionalsAvailabilityRaw(
        widget.order.scheduledDate ?? DateTime.now(),
        DateFormat('HH:mm').format(widget.order.scheduledDate ?? DateTime.now()),
        widget.order.originAddress.latitude ?? 0,
        widget.order.originAddress.longitude ?? 0,
        serviceIds: '',
      );

      if (!mounted) return;
      setState(() {
        // Filtra apenas profissionais com isFreight = true
        _professionals = all.where((p) => p.isFreight).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendRequest() async {
    setState(() => _isSending = true);
    try {
      final data = {
        ...widget.order.toJson(),
        if (_selectedProfessionalId != null)
          'professionalId': _selectedProfessionalId,
      };

      final success = await _freightRepo.create(data);

      if (!mounted) return;

      if (success) {
        Toastfy.show(context, 'Pedido de frete enviado com sucesso!', 'success');
        // Volta até a home removendo todas as telas do frete
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Toastfy.show(context, 'Não foi possível enviar o pedido.', 'error');
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profissionais Disponíveis',
          style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Resumo do pedido
            _buildOrderSummaryBar(),
            // Lista de profissionais
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold))
                  : _professionals.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadProfessionals,
                          color: AppColors.primaryGold,
                          backgroundColor: AppColors.cardBackground,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: _professionals.length,
                            itemBuilder: (context, index) {
                              return _buildProfessionalCard(
                                  _professionals[index]);
                            },
                          ),
                        ),
            ),
            // Botão de envio
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: PrimaryButton(
                text: _selectedProfessionalId != null
                    ? 'Solicitar Profissional Selecionado'
                    : 'Solicitar Qualquer Profissional',
                isLoading: _isSending,
                onPressed: _professionals.isEmpty ? null : _sendRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryBar() {
    final o = widget.order;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded,
                  color: AppColors.success, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  o.originAddress.shortDisplay.isNotEmpty
                      ? o.originAddress.shortDisplay
                      : o.originAddress.street,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.errorRed, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  o.destinationAddress.shortDisplay.isNotEmpty
                      ? o.destinationAddress.shortDisplay
                      : o.destinationAddress.street,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSummaryChip(Icons.inventory_2_rounded, o.cargoType),
              const SizedBox(width: 8),
              _buildSummaryChip(Icons.scale_rounded,
                  '${o.cargoWeight.toStringAsFixed(0)} kg'),
              const Spacer(),
              Text(
                UtilBrasilFields.obterReal(o.price),
                style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(ProfessionalModel p) {
    final isSelected = _selectedProfessionalId == p.profileId;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedProfessionalId = isSelected ? null : p.profileId;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.cardElevated,
              backgroundImage:
                  p.profileImageUrl.isNotEmpty ? NetworkImage(p.profileImageUrl) : null,
              child: p.profileImageUrl.isEmpty
                  ? Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                      style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  if (p.city.isNotEmpty || p.state.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      [p.city, p.state]
                          .where((s) => s.isNotEmpty)
                          .join(' - '),
                      style: GoogleFonts.inter(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                  if (p.rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.primaryGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          p.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        if (p.reviewCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${p.reviewCount})',
                            style: GoogleFonts.inter(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Seleção
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primaryGold, size: 22)
            else
              const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.person_search_rounded,
            size: 64, color: AppColors.textMuted),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Nenhum profissional de frete disponível',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Você ainda pode enviar o pedido e aguardar um profissional aceitar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
