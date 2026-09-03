import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../data/models/appointment/appointment_model.dart';
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

  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  bool _isProfessional = false;
  DateTime _selectedDay = DateTime.now();
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
    final role = (user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');

    if (mounted) {
      setState(() {
        _appointments = appointments;
        _isProfessional = isPro;
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
              'Serviço aceito! O cliente foi notificado.',
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
              'Solicitação recusada.',
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
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Não',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Sim, Cancelar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _appointmentRepo.deleteAppointment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Agendamento cancelado.' : 'Não foi possível cancelar o agendamento.',
              style: GoogleFonts.inter(
                color: success ? AppColors.textDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: success ? AppColors.primaryGold : AppColors.errorRed,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  List<AppointmentModel> get _appointmentsOnSelectedDay {
    return _appointments.where((a) {
      return a.date.year == _selectedDay.year &&
          a.date.month == _selectedDay.month &&
          a.date.day == _selectedDay.day;
    }).toList();
  }

  Set<int> _daysWithAppointments(int year, int month) {
    return _appointments
        .where((a) => a.date.year == year && a.date.month == month)
        .map((a) => a.date.day)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: _isProfessional ? 'Minha Agenda' : 'Meus Agendamentos',
        onProfileTap: widget.onNavigateToProfile,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : _isProfessional
                  ? _buildProfessionalView()
                  : _buildCustomerView(),
        ),
      ),
      bottomNavigationBar: (!_isLoading && !_isProfessional)
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
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
            )
          : null,
    );
  }

  Widget _buildProfessionalView() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDay.year, _selectedDay.month, 1);
    final daysInMonth = DateTime(_selectedDay.year, _selectedDay.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    final busyDays = _daysWithAppointments(_selectedDay.year, _selectedDay.month);
    final dayAppointments = _appointmentsOnSelectedDay;

    final pending = _appointments.where((a) {
      final s = a.status.toLowerCase();
      return s.contains('pending') || s.contains('request') || s == 'paid' || s.contains('aguardando');
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        if (pending.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${pending.length} solicitação(ões) aguardando sua resposta.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                    onPressed: () {
                      setState(() {
                        _selectedDay = DateTime(_selectedDay.year, _selectedDay.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDay),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                    onPressed: () {
                      setState(() {
                        _selectedDay = DateTime(_selectedDay.year, _selectedDay.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'].map((d) {
                  return SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startWeekday + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < startWeekday) return const SizedBox.shrink();
                  final day = index - startWeekday + 1;
                  final date = DateTime(_selectedDay.year, _selectedDay.month, day);
                  final isSelected = _selectedDay.day == day &&
                      _selectedDay.month == date.month &&
                      _selectedDay.year == date.year;
                  final isToday = now.day == day && now.month == date.month && now.year == date.year;
                  final hasTrampo = busyDays.contains(day);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGold
                            : isToday
                                ? AppColors.primaryGold.withValues(alpha: 0.15)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.textDark
                                  : isToday
                                      ? AppColors.primaryGold
                                      : AppColors.textPrimary,
                            ),
                          ),
                          if (hasTrampo)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.textDark : AppColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              DateFormat("dd 'de' MMMM", 'pt_BR').format(_selectedDay),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${dayAppointments.length} trampo(s)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (dayAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.event_available_rounded, color: AppColors.textMuted, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'Nenhum trampo neste dia.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mantenha-se disponível para receber novos chamados.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...dayAppointments.map((apt) => _buildProAppointmentCard(apt)),
        const SizedBox(height: 24),
        if (_appointments.isNotEmpty) ...[
          Text(
            'Todos os Agendamentos',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          ..._appointments.map((apt) => _buildProAppointmentCard(apt, showAll: true)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProAppointmentCard(AppointmentModel apt, {bool showAll = false}) {
    final st = apt.status.toLowerCase();
    String statusDisplay;
    Color statusColor;

    if (st == 'pending' || st == 'pendingpayment' || st == 'paid' || st == 'requested') {
      statusDisplay = 'Aguardando Aceite';
      statusColor = AppColors.primaryGold;
    } else if (st == 'accepted' || st == 'confirmed') {
      statusDisplay = 'Confirmado';
      statusColor = AppColors.success;
    } else if (st == 'declined') {
      statusDisplay = 'Recusado';
      statusColor = AppColors.errorRed;
    } else if (st == 'completed' || st == 'concluido' || st == 'finished') {
      statusDisplay = 'Concluído';
      statusColor = AppColors.textMuted;
    } else if (st == 'cancelled' || st == 'canceled') {
      statusDisplay = 'Cancelado';
      statusColor = AppColors.errorRed;
    } else {
      statusDisplay = apt.status;
      statusColor = AppColors.textMuted;
    }

    final isPendingAcceptance = st == 'pending' || st == 'pendingpayment' || st == 'paid' || st == 'requested';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPendingAcceptance
              ? AppColors.primaryGold.withValues(alpha: 0.6)
              : AppColors.cardBorder,
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
                  statusDisplay,
                  style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              if (apt.price != null && apt.price! > 0)
                Text(
                  'R\$ ${apt.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 15, fontWeight: FontWeight.w800),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            apt.serviceName ?? apt.categoryName ?? 'Serviço Agendado',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          if (apt.customerName != null && apt.customerName!.isNotEmpty)
            _infoRow(Icons.person_outline_rounded, 'Cliente: ${apt.customerName}'),
          _infoRow(
            Icons.access_time_rounded,
            '${DateFormat("dd/MM/yyyy", 'pt_BR').format(apt.date)}${apt.hour.isNotEmpty ? " • ${apt.hour}" : ""}',
          ),
          if (apt.address != null && apt.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, apt.address!),
          if (apt.description != null && apt.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow(Icons.notes_rounded, apt.description!),
          ],
          if (isPendingAcceptance) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAcceptAppointment(apt.id),
                    icon: const Icon(Icons.check_rounded, color: AppColors.textDark, size: 18),
                    label: Text(
                      'Aceitar',
                      style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleDeclineAppointment(apt.id),
                    icon: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 18),
                    label: Text(
                      'Recusar',
                      style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerView() {
    final filters = ['Todos', 'Pendentes', 'Confirmados', 'Concluídos'];

    final filteredAppointments = _appointments.where((apt) {
      if (_selectedFilterIndex == 0) return true;
      final filter = filters[_selectedFilterIndex].toLowerCase();
      final status = apt.status.toLowerCase();
      if (filter == 'pendentes') {
        return status.contains('pending') || status.contains('paid') || status.contains('requested');
      }
      if (filter == 'confirmados') {
        return status.contains('accept') || status.contains('confirm');
      }
      if (filter == 'concluídos') {
        return status.contains('complet') || status.contains('finaliz') || status.contains('conclu');
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
                    final st = apt.status.toLowerCase();

                    String statusDisplay;
                    Color statusColor;

                    if (st == 'pendingpayment') {
                      statusDisplay = 'Aguardando Pagamento';
                      statusColor = AppColors.primaryGold;
                    } else if (st == 'paid' || st == 'requested' || st == 'pending') {
                      statusDisplay = 'Aguardando Aceite';
                      statusColor = AppColors.primaryGold;
                    } else if (st == 'accepted' || st == 'confirmed') {
                      statusDisplay = 'Confirmado';
                      statusColor = AppColors.success;
                    } else if (st == 'declined') {
                      statusDisplay = 'Recusado';
                      statusColor = AppColors.errorRed;
                    } else if (st == 'completed' || st == 'concluido' || st == 'finished') {
                      statusDisplay = 'Concluído';
                      statusColor = AppColors.textMuted;
                    } else if (st == 'cancelled' || st == 'canceled') {
                      statusDisplay = 'Cancelado';
                      statusColor = AppColors.errorRed;
                    } else {
                      statusDisplay = apt.status;
                      statusColor = AppColors.textMuted;
                    }

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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusDisplay,
                                  style: GoogleFonts.inter(
                                    color: statusColor,
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
                            apt.serviceName ?? apt.categoryName ?? 'Diária de Serviço',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (apt.professionalName != null && apt.professionalName!.isNotEmpty)
                            _infoRow(Icons.engineering_outlined, 'Profissional: ${apt.professionalName}'),
                          _infoRow(
                            Icons.access_time_rounded,
                            '${DateFormat("dd/MM/yyyy", 'pt_BR').format(apt.date)}${apt.hour.isNotEmpty ? " • ${apt.hour}" : ""}',
                          ),
                          if (apt.address != null && apt.address!.isNotEmpty)
                            _infoRow(Icons.location_on_outlined, apt.address!),
                          if (st != 'completed' && st != 'concluido' && st != 'finished' && st != 'cancelled' && st != 'canceled') ...[
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.cardBorder, height: 1),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _handleCancelAppointment(apt.id),
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
                  },
                ),
        ),
      ],
    );
  }
}
