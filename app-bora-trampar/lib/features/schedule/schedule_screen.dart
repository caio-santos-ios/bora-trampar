import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../data/models/appointment/appointment_model.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/repositories/appointment/appointment_repository.dart';
import '../categories/category_selection_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const ScheduleScreen({super.key, this.onNavigateToProfile});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  UserModel? _user;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    final appointments = await _appointmentRepo.getAppointments();

    if (mounted) {
      setState(() {
        _user = user;
        _appointments = appointments;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAcceptAppointment(String appointmentId) async {
    final success = await _appointmentRepo.acceptAppointment(appointmentId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Serviço aceito com sucesso! O cliente foi notificado.',
              style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primaryGold,
          ),
        );
        _loadData();
      }
    }
  }

  Future<void> _handleDeclineAppointment(String appointmentId) async {
    final success = await _appointmentRepo.declineAppointment(appointmentId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Serviço recusado.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
        _loadData();
      }
    }
  }

  Future<void> _handleCancelAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      final success = await _appointmentRepo.deleteAppointment(appointmentId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Agendamento cancelado com sucesso.',
                style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primaryGold,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível cancelar o agendamento.',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = (_user?.role ?? '').toLowerCase() != 'profissional';
    final filters = isCustomer
        ? ['Todos', 'Confirmados', 'Concluídos']
        : ['Todos', 'Pendentes', 'Confirmados', 'Finalizados'];

    final filteredAppointments = _appointments.where((apt) {
      if (_selectedFilterIndex == 0) return true;
      final filter = filters[_selectedFilterIndex].toLowerCase();
      final status = apt.status.toLowerCase();
      if (filter == 'pendentes') {
        return status.contains('pending') || status.contains('paid');
      }
      if (filter == 'confirmados') {
        return status.contains('accept') || status.contains('confirm');
      }
      if (filter == 'concluídos' || filter == 'finalizados') {
        return status.contains('concluido') || status.contains('finalizado');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Agenda',
        onProfileTap: widget.onNavigateToProfile,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _loadData,
          child: Column(
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
                            color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
                            ),
                          ),
                          onSelected: (_) => setState(() => _selectedFilterIndex = index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGold),
                      )
                    : filteredAppointments.isEmpty
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
                                    isCustomer
                                        ? 'Você ainda não possui serviços agendados.'
                                        : 'Você não tem solicitações de diárias no momento.',
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: filteredAppointments.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final apt = filteredAppointments[index];
                              final dateFormatted = DateFormat("dd 'de' MMMM '•' HH:mm", 'pt_BR').format(apt.date);

                              String statusDisplay = 'Confirmado';
                              Color statusColor = AppColors.success;
                              final st = apt.status.toLowerCase();

                              if (st == 'pendingpayment') {
                                statusDisplay = 'Aguardando Pagamento';
                                statusColor = AppColors.primaryGold;
                              } else if (st == 'pendingacceptance' || st == 'paid') {
                                statusDisplay = 'Aguardando Aceite';
                                statusColor = AppColors.primaryGold;
                              } else if (st == 'accepted') {
                                statusDisplay = 'Aceito • Confirmado';
                                statusColor = AppColors.success;
                              } else if (st == 'declined') {
                                statusDisplay = 'Recusado';
                                statusColor = AppColors.errorRed;
                              } else if (st == 'completed' || st == 'concluido') {
                                statusDisplay = 'Concluído';
                                statusColor = AppColors.textMuted;
                              }

                              final isPendingAcceptance = st == 'pendingacceptance' || st == 'paid';

                              return _buildAppointmentCard(
                                id: apt.id,
                                title: apt.serviceName ?? 'Diária de Serviço',
                                professionalName: isCustomer
                                    ? (apt.professionalName ?? 'Profissional Designado')
                                    : (apt.customerName ?? 'Cliente Contratante'),
                                dateText: '$dateFormatted ${apt.hour}',
                                address: apt.address ?? 'São Paulo, SP',
                                status: statusDisplay,
                                statusColor: statusColor,
                                priceText: apt.price != null
                                    ? 'R\$ ${apt.price!.toStringAsFixed(2).replaceAll('.', ',')}'
                                    : 'R\$ 200,00',
                                isProfessionalView: !isCustomer,
                                isPendingAcceptance: isPendingAcceptance,
                                onAccept: () => _handleAcceptAppointment(apt.id),
                                onDecline: () => _handleDeclineAppointment(apt.id),
                                onCancel: () => _handleCancelAppointment(apt.id),
                              );
                            },
                          ),
              ),
              if (isCustomer)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String id,
    required String title,
    required String professionalName,
    required String dateText,
    required String address,
    required String status,
    required Color statusColor,
    required String priceText,
    bool isProfessionalView = false,
    bool isPendingAcceptance = false,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPendingAcceptance ? AppColors.primaryGold.withValues(alpha: 0.8) : AppColors.cardBorder,
        ),
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                priceText,
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
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isProfessionalView ? Icons.person_outline : Icons.engineering_outlined,
                color: AppColors.textMuted,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                professionalName,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 15),
              const SizedBox(width: 6),
              Text(
                dateText,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (isProfessionalView && isPendingAcceptance) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded, color: AppColors.textDark, size: 18),
                      label: Text(
                        'Aceitar Serviço',
                        style: GoogleFonts.inter(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Recusar',
                      style: GoogleFonts.inter(
                        color: AppColors.errorRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (id.isNotEmpty && onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 16),
                label: Text(
                  'Cancelar Diária',
                  style: GoogleFonts.inter(
                    color: AppColors.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
