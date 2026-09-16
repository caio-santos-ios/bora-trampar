import 'dart:async';
import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../models/freight_order_model.dart';
import '../../repositories/freight_order/freight_order_repository.dart';

class ProfessionalFreightScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const ProfessionalFreightScreen({super.key, this.onNavigateToProfile});

  @override
  State<ProfessionalFreightScreen> createState() =>
      _ProfessionalFreightScreenState();
}

class _ProfessionalFreightScreenState extends State<ProfessionalFreightScreen>
    with SingleTickerProviderStateMixin {
  final _freightRepo = FreightOrderRepository();

  late TabController _tabController;
  List<FreightOrderModel> _availableOrders = [];
  List<FreightOrderModel> _myOrders = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _reloadSilently();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final allAvailable = await _freightRepo.get();
      final mine = await _freightRepo.getMyOrdersAsProfessional();

      if (mounted) {
        setState(() {
          _availableOrders = allAvailable
              .where((o) => o.status.toLowerCase() == 'pending')
              .toList();
          _myOrders = mine;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadSilently() async {
    try {
      final allAvailable = await _freightRepo.get();
      final mine = await _freightRepo.getMyOrdersAsProfessional();

      if (mounted) {
        setState(() {
          _availableOrders = allAvailable
              .where((o) => o.status.toLowerCase() == 'pending')
              .toList();
          _myOrders = mine;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleAcceptFreight(FreightOrderModel order) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primaryGold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aceitar Frete',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Confirme que você realizará este transporte.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor: ${UtilBrasilFields.obterReal(order.price)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Origem: ${order.originAddress}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destino: ${order.destinationAddress}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Voltar',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Confirmar',
                        style: GoogleFonts.inter(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        final success = await _freightRepo.accept(order.id);
        if (success) {
          if (mounted) {
            Toastfy.show(context, "Frete aceito com sucesso!", "success");
            _loadData();
          }
        } else {
          if (mounted) {
            Toastfy.show(context, "Não foi possível aceitar este frete.", "error");
          }
        }
      } on DioException catch (err) {
        if (mounted) UtilService.normalizeError(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Fretes',
        onProfileTap: widget.onNavigateToProfile,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.cardBackground,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryGold,
                labelColor: AppColors.primaryGold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    text: 'Disponíveis (${_availableOrders.length})',
                  ),
                  Tab(
                    text: 'Meus Fretes (${_myOrders.length})',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAvailableList(),
                        _buildMyFreightList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableList() {
    if (_availableOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryGold,
        backgroundColor: AppColors.cardBackground,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Nenhum frete disponível no momento',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Fique atento às notificações para novos pedidos.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGold,
      backgroundColor: AppColors.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _availableOrders.length,
        itemBuilder: (context, index) {
          final order = _availableOrders[index];
          return _buildFreightCard(order, isAvailable: true);
        },
      ),
    );
  }

  Widget _buildMyFreightList() {
    if (_myOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryGold,
        backgroundColor: AppColors.cardBackground,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Você ainda não aceitou nenhum frete',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGold,
      backgroundColor: AppColors.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _myOrders.length,
        itemBuilder: (context, index) {
          final order = _myOrders[index];
          return _buildFreightCard(order, isAvailable: false);
        },
      ),
    );
  }

  Widget _buildFreightCard(FreightOrderModel order, {required bool isAvailable}) {
    final dateStr = order.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!.toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.vehicleType.isNotEmpty ? order.vehicleType : 'Frete',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status.toLowerCase() == 'accepted'
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: GoogleFonts.inter(
                    color: order.status.toLowerCase() == 'accepted'
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: AppColors.primaryGold,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.originAddress,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.errorRed,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.destinationAddress,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (order.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              order.description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor Estimado',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    UtilBrasilFields.obterReal(order.price),
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
              if (isAvailable)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => _handleAcceptFreight(order),
                  icon: const Icon(
                    Icons.check_rounded,
                    color: AppColors.textDark,
                    size: 18,
                  ),
                  label: Text(
                    'Aceitar',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                )
              else if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
