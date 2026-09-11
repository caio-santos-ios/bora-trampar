import 'dart:async';
import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_1_screen.dart';
import 'package:app_bora_trampar/pages/customer/customer_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/contestation/contestation_repository.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerAppointmentScreenState();
}

class _CustomerAppointmentScreenState extends State<CustomerOrderScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  final _storageService = StorageService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;
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
    String query = "customer_id=${_storageService.getCurrentUser().id}&orderBy=date";
    final fresh = await _appointmentRepo.getAppointments(query: query);
    if (mounted && fresh.isNotEmpty) {
      setState(() {
        _appointments = fresh;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    String query = "customer_id=${_storageService.getCurrentUser().id}&orderBy=date";
    final appointments = await _appointmentRepo.getAppointments(query: query);

    if (mounted) {
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
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
      default:
        return "";
    }
  }

  Color _normalizeStatusColor(String status) {
    switch (status) {
      case "Finish":
      case "Accepted":
        return Colors.green;
      case "FinishProfessional":
      case "PendingPayment":
        return Colors.orangeAccent;
      case "PendingAcceptance":
        return Colors.blueAccent;
      case "StartService":
        return Colors.purpleAccent;
      case "Disputed":
        return Colors.orange;
      case "Declined":
      case "CancelledByCustomer":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDisputeDialog(String appointmentId) async {
    final reasonController = TextEditingController();
    String selectedReason = 'Serviço incompleto';
    final reasons = [
      'Serviço incompleto',
      'Serviço não realizado',
      'Qualidade insatisfatória',
      'Cobrança indevida',
      'Outro motivo',
    ];
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contestar Serviço',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informe o motivo da contestação. O valor permanecerá retido no sistema até a análise do suporte para reembolso.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Motivo principal *',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      dropdownColor: AppColors.cardBackground,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      items: reasons
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Descrição detalhada *',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Explique o que aconteceu com detalhes...',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final desc = reasonController.text.trim();
                      if (desc.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, informe uma descrição detalhada.'),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      final success = await ContestationRepository().createContestation(
                        appointmentId: appointmentId,
                        reason: selectedReason,
                        description: desc,
                      );

                      if (!mounted) return;
                      Navigator.of(ctx).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Contestação registrada com sucesso! O caso foi encaminhado para análise.'
                                : 'Falha ao registrar contestação. Tente novamente.',
                          ),
                          backgroundColor:
                              success ? AppColors.primaryGold : AppColors.errorRed,
                        ),
                      );

                      if (success) _loadData();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar Contestação',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(title: 'Meus Agendamentos'),
      body: SafeArea(
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
              : _buildCustomerView(),
        ),
      ),
      bottomNavigationBar: (!_isLoading)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerOrderTab1Screen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textDark,
                  ),
                  label: Text(
                    'Agendar Novo Serviço',
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
    final filters = ['Todos', 'Pendentes', 'Você Cancelou', 'Profissional Recusou', 'Confirmados', 'Concluídos'];

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
                                  'R\$ ${apt.price!.toStringAsFixed(2).replaceAll('.', ',')}',
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
                              st != "CancelledByCustomer" && st != "FinishProfessional") ...[
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
                                  onPressed: () => _showDisputeDialog(apt.id),
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
}
