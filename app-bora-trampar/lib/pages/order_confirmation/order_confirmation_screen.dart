import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/order_request_model.dart';
import '../../models/professional_model.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/payment/payment_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/user/user_repository.dart';
import '../order_tracking/order_tracking_screen.dart';
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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _resolveProfessionalPrice();
  }

  Future<void> _resolveProfessionalPrice() async {
    final prof = widget.orderRequest.selectedProfessional;
    if (prof != null && prof.id.isNotEmpty) {
      final profile = await ProfileProfessionalRepository().getByUserId(prof.id);
      if (profile != null && profile.services.isNotEmpty) {
        final matching = profile.services.firstWhere(
          (s) => widget.orderRequest.selectedServices.any((sel) => sel.id == s.serviceId || sel.name.toLowerCase() == s.serviceName.toLowerCase()),
          orElse: () => profile.services.firstWhere((s) => s.price > 0, orElse: () => profile.services.first),
        );
        double resolvedPrice = matching.price > 0 ? matching.price : 0.0;
        if (resolvedPrice <= 0) {
          for (final s in profile.services) {
            if (s.price > 0) {
              resolvedPrice = s.price;
              break;
            }
          }
        }
        if (resolvedPrice > 0 && resolvedPrice != prof.basePrice) {
          if (mounted) {
            setState(() {
              widget.orderRequest.selectedProfessional = ProfessionalModel(
                id: prof.id,
                name: prof.name,
                role: prof.role,
                avatarUrl: prof.avatarUrl,
                isVerified: prof.isVerified,
                isAvailable: prof.isAvailable,
                rating: prof.rating,
                reviewCount: prof.reviewCount,
                completedServicesCount: prof.completedServicesCount,
                highlightBadge: prof.highlightBadge,
                basePrice: resolvedPrice,
                arrivalTimeMinutes: prof.arrivalTimeMinutes,
                sinceYear: prof.sinceYear,
                responseTime: prof.responseTime,
                completionRate: prof.completionRate,
                bio: prof.bio,
                offeredServices: prof.offeredServices,
                reviews: prof.reviews,
                region: prof.region,
              );
            });
          }
        }
      }
    }
  }

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
    if (_isSubmitting) return;
    _isSubmitting = true;
    setState(() {});

    final user = await AuthService().getCurrentUser();
    final customerId = user?.id ?? 'customer_default';
    final profId = widget.orderRequest.selectedProfessional?.id ?? 'prof_default';
    final date = widget.orderRequest.scheduledDate ?? DateTime.now();
    final hour = widget.orderRequest.scheduledTimeSlot;

    final catId = widget.orderRequest.selectedCategory?.id ?? '';
    final srvId = widget.orderRequest.selectedServices.isNotEmpty
        ? widget.orderRequest.selectedServices.first.id
        : '';

    final amountToPay = widget.orderRequest.amountToPay;
    final remainingCredit = widget.orderRequest.remainingCredit;
    final isFullyCovered = amountToPay <= 0;

    final appointment = await AppointmentRepository().createAppointment(
      professionalId: profId,
      customerId: customerId,
      date: date,
      hour: hour,
      status: isFullyCovered ? 'PendingAcceptance' : 'PendingPayment',
      categoryId: catId,
      serviceId: srvId,
      address: widget.orderRequest.address,
      description: widget.orderRequest.description,
      notes: widget.orderRequest.notes,
      photoUrls: widget.orderRequest.photoPaths,
      totalPrice: widget.orderRequest.servicePrice,
    );

    if (appointment == null || appointment.id.isEmpty) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao registrar solicitação. Verifique sua conexão e tente novamente.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final appointmentId = appointment.id;

    if (isFullyCovered) {
      if (remainingCredit > 0) {
        await UserRepository().creditWallet(remainingCredit, reason: 'Sobra de troca de profissional');
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remainingCredit > 0
                ? 'Solicitação enviada! A sobra de R\$ ${remainingCredit.toStringAsFixed(2).replaceAll('.', ',')} foi adicionada ao seu saldo.'
                : 'Solicitação enviada com sucesso sem custo adicional!',
            style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            orderRequest: widget.orderRequest,
            appointmentId: appointmentId,
          ),
        ),
      );
      return;
    }

    final paymentData = await PaymentRepository().createAsaasPixPayment(
      appointmentId: appointmentId,
      value: amountToPay,
      customerName: user?.name ?? 'Cliente',
    );

    final paymentId = paymentData?['id']?.toString() ??
        paymentData?['_id']?.toString() ??
        paymentData?['asaasId']?.toString() ??
        '';
    final qrCodeImage = paymentData?['qrCodeImage']?.toString() ??
        paymentData?['qr_code_image']?.toString() ??
        '';
    final qrCodePayload = paymentData?['qrCodePayload']?.toString() ??
        paymentData?['qr_code_payload']?.toString() ??
        '';

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (paymentData == null || qrCodePayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao gerar cobrança PIX no Asaas. Tente novamente.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

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
    final creditApplied = widget.orderRequest.creditApplied;
    final amountToPay = widget.orderRequest.amountToPay;
    final remainingCredit = widget.orderRequest.remainingCredit;

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AppStepper(totalSteps: 5, currentStep: 5),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            'Diária do profissional',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'R\$ ${servicePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (creditApplied > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Crédito já pago (anterior)',
                              style: GoogleFonts.inter(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '- R\$ ${creditApplied.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                      if (remainingCredit > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sobra adicionada ao seu saldo',
                              style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '+ R\$ ${remainingCredit.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            amountToPay > 0 ? 'Diferença a pagar' : 'Total a pagar agora',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'R\$ ${amountToPay.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              color: amountToPay > 0 ? AppColors.primaryGold : AppColors.success,
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
                  text: _isSubmitting
                      ? 'Processando...'
                      : (amountToPay <= 0
                          ? 'Confirmar solicitação (Sem custo)'
                          : (creditApplied > 0
                              ? '🔒 Pagar diferença (R\$ ${amountToPay.toStringAsFixed(2).replaceAll('.', ',')})'
                              : '🔒 Confirmar e solicitar profissional')),
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _onConfirmOrder,
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
