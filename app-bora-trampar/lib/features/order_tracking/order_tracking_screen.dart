import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/order_request_model.dart';
import '../onboarding/welcome_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const OrderTrackingScreen({super.key, required this.orderRequest});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isConfirmed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showCancelDialog() {
    showDialog(
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
            'Você não será cobrado caso cancele agora.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Manter',
                style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prof = widget.orderRequest.selectedProfessional;
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final dateDisplay = widget.orderRequest.scheduledDate != null
        ? DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.orderRequest.scheduledDate!)
        : '29 de agosto de 2026';

    final progress = _remainingSeconds / 30.0;
    final formattedTime = '00:${_remainingSeconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Acompanhar pedido',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryGold),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Countdown Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          color: const Color(0xFF1E1A10),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isConfirmed ? 'Profissional Confirmado!' : 'Aguardando confirmação',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isConfirmed
                                  ? 'Carlos aceitou o serviço e está a caminho!'
                                  : 'O profissional tem 30 segundos para aceitar sua solicitação.',
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
                      // Circular Progress Ring
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _isConfirmed ? 1.0 : progress,
                              strokeWidth: 3.5,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isConfirmed ? AppColors.success : AppColors.primaryGold,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isConfirmed ? '✓ OK' : formattedTime,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Tempo restante',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Lightning alert box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E190E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Assim que o profissional aceitar, você será notificado imediatamente.',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status Timeline Stepper
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimelineStep(
                        icon: Icons.send_rounded,
                        title: 'Solicitação\nenviada',
                        subtitle: '29/08 14:05',
                        isCompleted: true,
                      ),
                      _buildTimelineConnector(isCompleted: true),
                      _buildTimelineStep(
                        icon: Icons.access_time_rounded,
                        title: 'Aguardando\nconfirmação',
                        subtitle: '',
                        isActive: !_isConfirmed,
                        isCompleted: _isConfirmed,
                      ),
                      _buildTimelineConnector(isCompleted: _isConfirmed),
                      _buildTimelineStep(
                        icon: Icons.calendar_today_outlined,
                        title: 'Serviço\nconfirmado',
                        subtitle: '',
                        isCompleted: false,
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
                ),
                const SizedBox(height: 20),

                // Profissional selecionado card
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(prof.avatarUrl),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    prof.name,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: AppColors.primaryGold, size: 15),
                                ],
                              ),
                              Text(
                                prof.role,
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
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
                              'A partir de',
                              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
                            ),
                            Text(
                              'R\$ ${prof.basePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, color: AppColors.primaryGold, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'Chega em até\n${prof.arrivalTimeMinutes} min',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Resumo do pedido card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo do pedido',
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
                          const Icon(Icons.foundation_rounded, color: AppColors.primaryGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Serviço', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                                Text(
                                  '$serviceName - ${widget.orderRequest.description.isNotEmpty ? widget.orderRequest.description : "Levantamento de parede no quintal"}',
                                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                                Text(dateDisplay, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Horário', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                                Text(widget.orderRequest.scheduledTimeSlot, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.attach_money_rounded, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Valor', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                                Text('R\$ ${widget.orderRequest.servicePrice.toStringAsFixed(2).replaceAll('.', ',')}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Fallback guarantee card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Não se preocupe!',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Se o profissional não aceitar em 30 segundos, buscaremos outro disponível automaticamente.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.watch_later_outlined, color: AppColors.textMuted, size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Button: "Cancelar solicitação"
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _showCancelDialog,
                icon: const Icon(Icons.close_rounded, color: AppColors.primaryGold, size: 18),
                label: Text(
                  'Cancelar solicitação',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
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
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
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
