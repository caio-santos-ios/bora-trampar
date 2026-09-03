import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/appointment/appointment_model.dart';
import '../../data/repositories/appointment/appointment_repository.dart';
import '../main/main_navigation_screen.dart';
import '../professionals/professionals_list_screen.dart';

enum TrackingStatus { waiting, accepted, declined, expired }

class OrderTrackingScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;
  final String appointmentId;

  const OrderTrackingScreen({
    super.key,
    required this.orderRequest,
    this.appointmentId = '',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  static const int _totalWaitSeconds = 900;
  int _remainingSeconds = _totalWaitSeconds;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  TrackingStatus _status = TrackingStatus.waiting;

  bool get _isToday {
    final date = widget.orderRequest.scheduledDate ?? DateTime.now();
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    if (_isToday) {
      _countdownTimer?.cancel();
      _remainingSeconds = _totalWaitSeconds;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 1) {
          if (mounted) {
            setState(() {
              _remainingSeconds--;
            });
          }
        } else {
          _countdownTimer?.cancel();
          if (mounted && _status == TrackingStatus.waiting) {
            setState(() {
              _remainingSeconds = 0;
              _status = TrackingStatus.expired;
            });
          }
        }
      });
    }

    _pollTimer?.cancel();
    _checkAppointmentStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkAppointmentStatus();
    });
  }

  Future<void> _checkAppointmentStatus() async {
    AppointmentModel? apt;
    if (widget.appointmentId.isNotEmpty) {
      apt = await _appointmentRepository.getAppointmentById(widget.appointmentId);
    }
    if (apt == null) {
      final all = await _appointmentRepository.getAppointments();
      if (all.isNotEmpty) {
        final profId = widget.orderRequest.selectedProfessional?.id;
        final matches = all.where((a) {
          if (widget.appointmentId.isNotEmpty && a.id == widget.appointmentId) return true;
          if (profId != null && profId.isNotEmpty && a.profissionalId == profId) return true;
          return false;
        }).toList();

        if (matches.isNotEmpty) {
          apt = matches.first;
        }
      }
    }

    if (!mounted || apt == null) return;

    final s = apt.status.toLowerCase();
    if (s == 'accepted' || s == 'aceito' || s == 'confirmed' || s == 'confirmado') {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();
      if (mounted) {
        setState(() {
          _status = TrackingStatus.accepted;
        });
      }
    } else if (s == 'declined' || s == 'recusado' || s == 'cancelled' || s == 'cancelado') {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();
      if (mounted) {
        setState(() {
          _status = TrackingStatus.declined;
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _chooseAnotherProfessional() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();

    final previouslyPaid = widget.orderRequest.creditApplied > 0
        ? (widget.orderRequest.creditApplied + widget.orderRequest.amountToPay)
        : widget.orderRequest.servicePrice;

    if (widget.appointmentId.isNotEmpty) {
      _appointmentRepository.deleteAppointment(widget.appointmentId);
    }

    widget.orderRequest.creditApplied = previouslyPaid;
    widget.orderRequest.previousAppointmentId = widget.appointmentId;
    widget.orderRequest.selectedProfessional = null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProfessionalsListScreen(orderRequest: widget.orderRequest),
      ),
    );
  }

  void _continueWaiting() {
    setState(() {
      _status = TrackingStatus.waiting;
      _remainingSeconds = _totalWaitSeconds;
    });
    _startTracking();
  }

  void _goToMyOrders() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialIndex: 1),
      ),
      (route) => false,
    );
  }

  Future<void> _cancelAppointment() async {
    final paidValue = widget.orderRequest.creditApplied > 0
        ? (widget.orderRequest.creditApplied + widget.orderRequest.amountToPay)
        : widget.orderRequest.servicePrice;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: Text(
            'Cancelar solicitação?',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Seu agendamento será cancelado e o valor de R\$ ${paidValue.toStringAsFixed(2).replaceAll('.', ',')} ficará como saldo positivo na sua conta para novos chamados.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Manter',
                style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();

      if (widget.appointmentId.isNotEmpty) {
        await _appointmentRepository.cancelByCustomer(widget.appointmentId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Agendamento cancelado pelo cliente. O valor de R\$ ${paidValue.toStringAsFixed(2).replaceAll('.', ',')} ficou como saldo positivo na sua carteira!',
            style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.primaryGold,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prof = widget.orderRequest.selectedProfessional;
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final dateDisplay = widget.orderRequest.scheduledDate != null
        ? DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.orderRequest.scheduledDate!)
        : 'Hoje, ${DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(DateTime.now())}';

    final progress = _remainingSeconds / _totalWaitSeconds.toDouble();
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_status == TrackingStatus.accepted || !_isToday) {
              _goToMyOrders();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Acompanhar pedido',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  _buildStatusHeaderCard(progress, formattedTime, dateDisplay),
                  const SizedBox(height: 14),
                  _buildInfoNoticeCard(dateDisplay),
                  const SizedBox(height: 20),
                  _buildTimelineStepper(),
                  const SizedBox(height: 20),
                  if (prof != null) ...[
                    Text(
                      'Profissional selecionado',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProfessionalInfoCard(prof),
                    const SizedBox(height: 16),
                  ],
                  _buildOrderSummaryCard(serviceName, dateDisplay),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard(double progress, String formattedTime, String dateDisplay) {
    Color cardBorderColor;
    Color iconBgColor;
    IconData icon;
    String title;
    String subtitle;
    Widget trailingWidget;

    switch (_status) {
      case TrackingStatus.accepted:
        cardBorderColor = AppColors.success.withValues(alpha: 0.5);
        iconBgColor = AppColors.success.withValues(alpha: 0.15);
        icon = Icons.check_circle_rounded;
        title = 'Profissional Confirmado!';
        subtitle = '${widget.orderRequest.selectedProfessional?.name ?? 'O profissional'} aceitou o serviço e está confirmado!';
        trailingWidget = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: AppColors.success, size: 28),
          ),
        );
        break;

      case TrackingStatus.declined:
        cardBorderColor = AppColors.errorRed.withValues(alpha: 0.5);
        iconBgColor = AppColors.errorRed.withValues(alpha: 0.15);
        icon = Icons.cancel_outlined;
        title = 'Solicitação não aceita';
        subtitle = '${widget.orderRequest.selectedProfessional?.name ?? 'O profissional'} não pôde atender a este chamado no momento.';
        trailingWidget = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.errorRed.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.errorRed, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.close_rounded, color: AppColors.errorRed, size: 28),
          ),
        );
        break;

      case TrackingStatus.expired:
        cardBorderColor = AppColors.primaryGold.withValues(alpha: 0.5);
        iconBgColor = const Color(0xFF1E1A10);
        icon = Icons.timer_off_outlined;
        title = 'Tempo de resposta esgotado';
        subtitle = '${widget.orderRequest.selectedProfessional?.name ?? 'O profissional'} não respondeu à solicitação a tempo.';
        trailingWidget = Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1A10),
            border: Border.all(color: AppColors.primaryGold, width: 2),
          ),
          child: Center(
            child: Text(
              '00:00',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        break;

      case TrackingStatus.waiting:
        cardBorderColor = AppColors.cardBorder;
        iconBgColor = const Color(0xFF1E1A10);
        icon = _isToday ? Icons.access_time_rounded : Icons.event_available_rounded;
        title = _isToday ? 'Aguardando confirmação' : 'Solicitação agendada enviada!';
        subtitle = _isToday
            ? 'O profissional tem até 60 segundos para responder à sua solicitação imediata.'
            : 'Aguardando confirmação de ${widget.orderRequest.selectedProfessional?.name ?? 'profissional'} para $dateDisplay.';
        trailingWidget = _isToday
            ? SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3.5,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Agendado',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
              color: iconBgColor,
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailingWidget,
        ],
      ),
    );
  }

  Widget _buildInfoNoticeCard(String dateDisplay) {
    if (_status == TrackingStatus.accepted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tudo pronto! O profissional entrará em contato ou comparecerá no horário agendado.',
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_status == TrackingStatus.declined || _status == TrackingStatus.expired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E190E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Você pode escolher outro profissional agora mesmo sem perder os dados da solicitação.',
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E190E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'O profissional tem até a véspera para confirmar. Você pode acompanhar o status em Meus Pedidos.',
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E190E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Assim que o profissional aceitar, seu pedido será confirmado imediatamente.',
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepper() {
    final isConfirmed = _status == TrackingStatus.accepted;
    final isDeclinedOrExpired = _status == TrackingStatus.declined || _status == TrackingStatus.expired;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTimelineStep(
            icon: Icons.send_rounded,
            title: 'Solicitação\nenviada',
            subtitle: '',
            isCompleted: true,
          ),
          _buildTimelineConnector(isCompleted: true),
          _buildTimelineStep(
            icon: Icons.access_time_rounded,
            title: 'Aguardando\nresposta',
            subtitle: '',
            isActive: _status == TrackingStatus.waiting,
            isCompleted: isConfirmed,
          ),
          _buildTimelineConnector(isCompleted: isConfirmed),
          _buildTimelineStep(
            icon: Icons.calendar_today_outlined,
            title: isDeclinedOrExpired ? 'Não\nconfirmado' : 'Serviço\nconfirmado',
            subtitle: '',
            isActive: false,
            isCompleted: isConfirmed,
          ),
          _buildTimelineConnector(isCompleted: false),
          _buildTimelineStep(
            icon: Icons.handyman_outlined,
            title: 'Serviço\nem andamento',
            subtitle: '',
            isCompleted: false,
          ),
          _buildTimelineConnector(isCompleted: false),
          _buildTimelineStep(
            icon: Icons.check_circle_outline_rounded,
            title: 'Serviço\nconcluído',
            subtitle: '',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoCard(dynamic prof) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.cardElevated,
            backgroundImage: prof.avatarUrl.isNotEmpty ? NetworkImage(prof.avatarUrl) : null,
            child: prof.avatarUrl.isEmpty
                ? Text(
                    prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'P',
                    style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w700),
                  )
                : null,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: AppColors.primaryGold, size: 15),
                  ],
                ),
                Text(
                  prof.role,
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${prof.rating.toStringAsFixed(1)} (${prof.reviewCount} avaliações)',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Valor do serviço',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
              ),
              Text(
                'R\$ ${prof.basePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(String serviceName, String dateDisplay) {
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
          Text(
            'Resumo da solicitação',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.build_outlined, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Serviço', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                    Text(serviceName, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data e Horário', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                    Text('$dateDisplay às ${widget.orderRequest.scheduledTimeSlot}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Endereço', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                    Text(widget.orderRequest.address, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    if (_status == TrackingStatus.accepted) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _goToMyOrders,
            icon: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.textDark, size: 18),
            label: Text(
              'Acompanhar em Meus Pedidos',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    if (_status == TrackingStatus.expired) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _chooseAnotherProfessional,
                icon: const Icon(Icons.replay_rounded, color: AppColors.textDark, size: 18),
                label: Text(
                  'Escolher outro profissional',
                  style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _continueWaiting,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Continuar aguardando',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelAppointment,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Cancelar solicitação',
                      style: GoogleFonts.inter(
                        color: AppColors.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_status == TrackingStatus.declined) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _chooseAnotherProfessional,
                icon: const Icon(Icons.people_outline_rounded, color: AppColors.textDark, size: 18),
                label: Text(
                  'Escolher outro profissional disponível',
                  style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: _cancelAppointment,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Cancelar e voltar ao início',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isToday) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _goToMyOrders,
                icon: const Icon(Icons.assignment_outlined, color: AppColors.textDark, size: 18),
                label: Text(
                  'Acompanhar em Meus Pedidos',
                  style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _cancelAppointment,
              child: Text(
                'Cancelar solicitação',
                style: GoogleFonts.inter(
                  color: AppColors.errorRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _cancelAppointment,
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryGold, size: 18),
          label: Text(
            'Cancelar solicitação',
            style: GoogleFonts.inter(
              color: AppColors.primaryGold,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? AppColors.primaryGold : AppColors.cardElevated,
            border: Border.all(
              color: isCompleted || isActive ? AppColors.primaryGold : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: isCompleted || isActive ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            color: isCompleted || isActive ? AppColors.primaryGold : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isCompleted || isActive ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? AppColors.primaryGold : AppColors.cardBorder,
    );
  }
}
