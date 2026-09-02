import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/order_request_model.dart';
import '../../data/repositories/appointment/appointment_repository.dart';
import '../../data/repositories/payment/payment_repository.dart';
import '../payment/payment_asaas_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const OrderConfirmationScreen({super.key, required this.orderRequest});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String _selectedPaymentMethod = 'PIX Instantâneo';

  void _showPaymentMethodModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forma de pagamento',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = 'PIX Instantâneo');
                    Navigator.of(context).pop();
                  },
                  leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryGold),
                  title: const Text('PIX (Asaas)'),
                  subtitle: const Text('Aprovação imediata'),
                  trailing: _selectedPaymentMethod.contains('PIX')
                      ? const Icon(Icons.check_rounded, color: AppColors.primaryGold)
                      : null,
                ),
                ListTile(
                  onTap: () {
                    setState(() => _selectedPaymentMethod = 'Cartão de Crédito final •••• 4242');
                    Navigator.of(context).pop();
                  },
                  leading: const Icon(Icons.credit_card_rounded, color: AppColors.primaryGold),
                  title: const Text('Cartão de Crédito'),
                  subtitle: const Text('Pagamento seguro Asaas'),
                  trailing: _selectedPaymentMethod.contains('4242')
                      ? const Icon(Icons.check_rounded, color: AppColors.primaryGold)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onConfirmOrder() async {
    final user = await AuthService().getCurrentUser();
    final customerId = user?.id ?? 'customer_default';
    final profId = widget.orderRequest.selectedProfessional?.id ?? 'prof_default';
    final date = widget.orderRequest.scheduledDate ?? DateTime.now();
    final hour = widget.orderRequest.scheduledTimeSlot;

    final appointment = await AppointmentRepository().createAppointment(
      professionalId: profId,
      customerId: customerId,
      date: date,
      hour: hour,
      status: 'PendingPayment',
      serviceNames: widget.orderRequest.serviceNamesDisplay,
      categoryName: widget.orderRequest.selectedCategory?.title ?? '',
      address: widget.orderRequest.address,
      description: widget.orderRequest.description,
      notes: widget.orderRequest.notes,
      photoUrls: widget.orderRequest.photoPaths,
      totalPrice: widget.orderRequest.totalPrice,
    );

    final appointmentId = appointment?.id ?? 'app_${DateTime.now().millisecondsSinceEpoch}';

    final paymentData = await PaymentRepository().createAsaasPixPayment(
      appointmentId: appointmentId,
      value: widget.orderRequest.totalPrice,
      customerName: user?.name ?? 'Cliente',
    );

    final paymentId = paymentData?['id']?.toString() ?? paymentData?['_id']?.toString() ?? 'pay_${DateTime.now().millisecondsSinceEpoch}';
    final qrCodeImage = paymentData?['qr_code_image']?.toString() ??
        'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=boratrampar_pix_asaas';
    final qrCodePayload = paymentData?['qr_code_payload']?.toString() ??
        '00020126580014br.gov.bcb.pix0136boratrampar@pix.com.br5204000053039865405';

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentAsaasScreen(
          orderRequest: widget.orderRequest,
          appointmentId: appointmentId,
          paymentId: paymentId,
          qrCodeImage: qrCodeImage,
          qrCodePayload: qrCodePayload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prof = widget.orderRequest.selectedProfessional;
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final dateDisplay = widget.orderRequest.scheduledDate != null
        ? DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.orderRequest.scheduledDate!)
        : 'Hoje, ${DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(DateTime.now())}';

    final servicePrice = widget.orderRequest.servicePrice;
    final appFee = widget.orderRequest.appFee;
    final totalPrice = widget.orderRequest.totalPrice;

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Central de Ajuda Bora Trampar',
                    style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
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
          // Stepper bar (Step 5 active)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AppStepper(totalSteps: 5, currentStep: 5),
          ),

          // Scrollable Content
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
                                TextSpan(text: 'Confira os detalhes\ne '),
                                TextSpan(
                                  text: 'finalize sua solicitação',
                                  style: TextStyle(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Revise as informações do serviço e confirme para solicitar o profissional.',
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

                // Card 1: Selected Professional
                if (prof != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                              Text(
                                'Profissional selecionado',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
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
                const SizedBox(height: 12),

                // Card 2: Requested Service
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
                                color: AppColors.textMuted,
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
                            Text(
                              widget.orderRequest.description.isNotEmpty
                                  ? widget.orderRequest.description
                                  : 'Levantamento de parede no quintal',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: [
                            Text(
                              'Alterar',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 3: Service Details
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detalhes do serviço',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.description_outlined,
                        title: 'Descrição',
                        value: widget.orderRequest.description.isNotEmpty
                            ? widget.orderRequest.description
                            : 'Preciso levantar uma parede no quintal, aproximadamente 4x3m.',
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Data',
                        value: dateDisplay,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.access_time_rounded,
                        title: 'Horário',
                        value: widget.orderRequest.scheduledTimeSlot,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.location_on_outlined,
                        title: 'Endereço',
                        value: widget.orderRequest.address,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 4: Resumo do pedido
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor do serviço (a partir de)',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'R\$ ${servicePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Taxa do app',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.textMuted),
                            ],
                          ),
                          Text(
                            'R\$ ${appFee.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'R\$ ${totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: AppColors.success, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Pagamento 100% seguro pelo app.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 5: Forma de pagamento
                InkWell(
                  onTap: _showPaymentMethodModal,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forma de pagamento',
                                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedPaymentMethod,
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Selecionar',
                              style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Reassurance banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          color: const Color(0xFF1E1A10),
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.primaryGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Você só paga após o serviço ser concluído',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'O pagamento fica retido e só é liberado para o profissional após você aprovar o serviço.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Button CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  text: '🔒 Confirmar e solicitar profissional',
                  onPressed: _onConfirmOrder,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Ao confirmar, você aceita os Termos de Uso.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 11,
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
  );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
