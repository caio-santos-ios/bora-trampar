import 'dart:async';
import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_1_screen.dart';
import 'package:app_bora_trampar/pages/customer/customer_reviews_screen.dart';
import 'package:app_bora_trampar/pages/customer/customer_create_contestation_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../repositories/appointment/appointment_repository.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../../models/freight_order_model.dart';
import '../../repositories/freight_order/freight_order_repository.dart';
import 'customer_freight_route_screen.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerAppointmentScreenState();
}

class _CustomerAppointmentScreenState extends State<CustomerOrderScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final FreightOrderRepository _freightRepo = FreightOrderRepository();

  final _storageService = StorageService();

  List<AppointmentModel> _appointments = [];
  List<FreightOrderModel> _freightOrders = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;
  int _selectedCategoryTab = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _reloadAppointmentsSilently();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _reloadAppointmentsSilently() async {
    try {
      String query =
          "customer_id=${_storageService.getCurrentUser().id}&orderBy=date";
      final fresh = await _appointmentRepo.getAppointments(query: query);
      final freshFreights = await _freightRepo.getMyOrdersAsCustomer();
      if (mounted) {
        setState(() {
          if (fresh.isNotEmpty) _appointments = fresh;
          _freightOrders = freshFreights;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      String query =
          "customer_id=${_storageService.getCurrentUser().id}&orderBy=date";
      final appointments = await _appointmentRepo.getAppointments(query: query);
      final freights = await _freightRepo.getMyOrdersAsCustomer();

      if (mounted) {
        setState(() {
          _appointments = appointments;
          _freightOrders = freights;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancelar Agendamento',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja cancelar esta diária agendada?',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Não',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sim, Cancelar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _appointmentRepo.cancelByCustomer(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Agendamento cancelado.'
                  : 'Não foi possível cancelar o agendamento.',
              style: GoogleFonts.inter(
                color: success ? AppColors.textDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: success
                ? AppColors.primaryGold
                : AppColors.errorRed,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  Future<void> _handleFinishAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Serviço finalizado',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Esse serviço será finalizado!',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Não',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGoldDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sim, Confirmar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _appointmentRepo.finishAppointment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Agendamento finalizado.'
                  : 'Não foi possível finalizar o agendamento.',
              style: GoogleFonts.inter(
                color: success ? AppColors.textDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: success
                ? AppColors.primaryGold
                : AppColors.errorRed,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  String _normalizeStatusName(String status) {
    switch (status) {
      case "Finish":
        return "Finalizado";
      case "FinishProfessional":
        return "Profissional Finalizou Serviço";
      case "PendingPayment":
        return "Pagamento Pendente";
      case "PendingAcceptance":
        return "Aguardando Profissional Aceitar";
      case "Accepted":
        return "Profissional Confirmou";
      case "Declined":
        return "Profissional Recusou";
      case "StartService":
        return "Profissional Iniciou Serviço";
      case "CancelledByCustomer":
        return "Cancelado";
      case "Disputed":
        return "Em Contestação";
      case "ExpenseProfessional":
        return "Contestação Perdida";
      case "ExpenseInfoRequest":
        return "Informar mais detalhes - Contestação";
      case "ExpenseCustomer":
        return "Reembolsado";
      case "ExpensePartialProfessional":
        return "Reembolsado Parcial";
      default:
        return "";
    }
  }

  Color _normalizeStatusColor(String status) {
    switch (status) {
      case "Finish":
      case "Accepted":
      case "ExpenseCustomer":
      case "ExpensePartialProfessional":
        return Colors.green;
      case "FinishProfessional":
      case "PendingPayment":
        return Colors.orangeAccent;
      case "PendingAcceptance":
      case "ExpenseInfoRequest":
        return Colors.blueAccent;
      case "StartService":
        return Colors.purpleAccent;
      case "Disputed":
        return Colors.orange;
      case "Declined":
      case "CancelledByCustomer":
      case "ExpenseProfessional":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(title: 'Meus Pedidos'),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopTabs(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGold,
                backgroundColor: AppColors.cardBackground,
                onRefresh: _loadData,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGold,
                        ),
                      )
                    : (_selectedCategoryTab == 0
                        ? _buildCustomerView()
                        : _buildFreightView()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!_isLoading)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedCategoryTab == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerOrderTab1Screen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerFreightRouteScreen(),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _selectedCategoryTab == 0
                        ? Icons.add_rounded
                        : Icons.local_shipping_rounded,
                    color: AppColors.textDark,
                  ),
                  label: Text(
                    _selectedCategoryTab == 0
                        ? 'Agendar Novo Serviço'
                        : 'Solicitar Novo Frete',
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerView() {
    final filters = [
      'Todos',
      'Pendentes',
      'Você Cancelou',
      'Profissional Recusou',
      'Confirmados',
      'Concluídos',
    ];

    final filteredAppointments = _appointments.where((apt) {
      if (_selectedFilterIndex == 0) return true;
      final filter = filters[_selectedFilterIndex];
      final status = apt.status;

      if (filter == 'Pendentes') {
        return status == "PendingAcceptance";
      }
      if (filter == 'Você Cancelou') {
        return status == "CancelledByCustomer";
      }
      if (filter == 'Profissional Recusou') {
        return status == "Declined";
      }
      if (filter == 'Confirmados') {
        return status == "Accepted";
      }
      if (filter == 'Concluídos') {
        return status == "Finish";
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    labelStyle: GoogleFonts.inter(
                      color: isSelected
                          ? AppColors.textDark
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    selectedColor: AppColors.primaryGold,
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.cardBorder,
                      ),
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedFilterIndex = index),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: filteredAppointments.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum agendamento encontrado',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Solicite um novo trampo na aba Home.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: filteredAppointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final apt = filteredAppointments[index];
                    final st = apt.status;

                    return Container(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _normalizeStatusColor(
                                    st,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _normalizeStatusName(st),
                                  style: GoogleFonts.inter(
                                    color: _normalizeStatusColor(st),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (apt.price != null && apt.price! > 0)
                                Text(
                                  UtilBrasilFields.obterReal(apt.price!),
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            apt.serviceName ??
                                apt.categoryName ??
                                'Diária de Serviço',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (apt.professionalName != null &&
                              apt.professionalName!.isNotEmpty)
                            _infoRow(
                              Icons.engineering_outlined,
                              'Profissional: ${apt.professionalName}',
                            ),
                          _infoRow(
                            Icons.access_time_rounded,
                            '${DateFormat("dd/MM/yyyy", 'pt_BR').format(apt.date)}${apt.hour.isNotEmpty ? " • ${apt.hour}" : ""}',
                          ),
                          if (apt.address != null && apt.address!.isNotEmpty)
                            _infoRow(Icons.location_on_outlined, apt.address!),

                          if (st != "Finish" &&
                              st != "Declined" &&
                              st != "CancelledByCustomer" &&
                              st != "FinishProfessional" &&
                              st != "Disputed" &&
                              st != "ExpenseProfessional" &&
                              st != "ExpenseInfoRequest" &&
                              st != "ExpenseCustomer" &&
                              st != "ExpensePartialProfessional") ...[
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _handleCancelAppointment(apt.id),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.errorRed,
                                  size: 16,
                                ),
                                label: Text(
                                  'Cancelar Diária',
                                  style: GoogleFonts.inter(
                                    color: AppColors.errorRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],

                          if (st == "FinishProfessional") ...[
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CustomerCreateContestationScreen(
                                              appointment: apt,
                                            ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadData();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.report_problem_outlined,
                                    color: AppColors.errorRed,
                                    size: 15,
                                  ),
                                  label: Text(
                                    'Contestar',
                                    style: GoogleFonts.inter(
                                      color: AppColors.errorRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () =>
                                      _handleFinishAppointment(apt.id),
                                  icon: const Icon(
                                    Icons.check,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Serviço foi finalizado',
                                    style: GoogleFonts.inter(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (st == "ExpenseInfoRequest") ...[
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGoldDark.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primaryGoldDark.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        color: AppColors.primaryGoldDark,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Mais informações solicitadas pela moderação',
                                          style: GoogleFonts.inter(
                                            color: AppColors.primaryGoldDark,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'A moderação necessita de esclarecimentos adicionais para dar continuidade à sua contestação.',
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result =
                                            await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CustomerCreateContestationScreen(
                                              appointment: apt,
                                              isAddingInfo: true,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadData();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.upload_file_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      label: Text(
                                        'Enviar Mais Informações',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGoldDark,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (st == "Finish" && apt.hasReviews.isEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerReviewsScreen(
                                            appointmenId: apt.id,
                                            customerId: apt.customerId,
                                            professionalId: apt.professionalId,
                                            serviceId: apt.serviceId,
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: AppColors.primaryGold,
                                  size: 16,
                                ),
                                label: Text(
                                  'Avaliar Serviço',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTopTabs() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTopTabItem(
              index: 0,
              label: 'Serviços (${_appointments.length})',
              icon: Icons.calendar_today_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTopTabItem(
              index: 1,
              label: 'Fretes (${_freightOrders.length})',
              icon: Icons.local_shipping_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategoryTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primaryGold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreightView() {
    if (_freightOrders.isEmpty) {
      return ListView(
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
              'Você não tem pedidos de frete',
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
              'Toque em "Solicitar Novo Frete" para calcular rota e contratar um transporte.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _freightOrders.length,
      itemBuilder: (context, index) {
        final order = _freightOrders[index];
        return _buildFreightCard(order);
      },
    );
  }

  Widget _buildFreightCard(FreightOrderModel order) {
    final dateStr = order.scheduledDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(order.scheduledDate!.toLocal())
        : (order.createdAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!.toLocal())
            : '');

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
                  order.cargoType.isNotEmpty ? order.cargoType : 'Frete',
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
                  color: _freightStatusColor(order.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: GoogleFonts.inter(
                    color: _freightStatusColor(order.status),
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
              const Icon(Icons.trip_origin_rounded,
                  color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.originAddress.toString(),
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
              const Icon(Icons.location_on_rounded,
                  color: AppColors.errorRed, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.destinationAddress.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (order.cargoWeight > 0 || order.vehicleType.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (order.cargoWeight > 0)
                  _freightTag(Icons.scale_rounded,
                      '${order.cargoWeight.toStringAsFixed(0)} kg'),
                if (order.cargoWeight > 0 && order.vehicleType.isNotEmpty)
                  const SizedBox(width: 8),
                if (order.vehicleType.isNotEmpty)
                  _freightTag(Icons.local_shipping_outlined, order.vehicleType),
              ],
            ),
          ],
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
          if (order.professionalName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Motorista: ${order.professionalName}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ] else if (order.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Aguardando aceite de motorista...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                    style:
                        GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
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
              if (order.status.toLowerCase() == 'pending')
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => _handleCancelFreight(order.id),
                  child: Text(
                    'Cancelar Frete',
                    style: GoogleFonts.inter(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style:
                      GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _freightStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'finished':
        return AppColors.success;
      case 'inprogress':
      case 'in_progress':
        return Colors.blueAccent;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return Colors.orangeAccent;
    }
  }

  Widget _freightTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelFreight(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancelar Frete',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja cancelar esta solicitação de frete?',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Voltar',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sim, Cancelar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _freightRepo.delete(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Frete cancelado com sucesso.'
                  : 'Não foi possível cancelar o frete.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor:
                success ? AppColors.primaryGold : AppColors.errorRed,
          ),
        );
        if (success) _loadData();
      }
    }
  }
}

