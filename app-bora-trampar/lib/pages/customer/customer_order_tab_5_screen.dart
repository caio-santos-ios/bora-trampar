import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_6_screen.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_7_screen.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/order_request_model.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/payment/payment_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/user/user_repository.dart';
import '../professional/professional_profile_screen.dart';

class CustomerOrderTab5Screen extends StatefulWidget {
  final OrderRequestModel orderRequest;
  final double price;

  const CustomerOrderTab5Screen({super.key, required this.orderRequest, required this.price});

  @override
  State<CustomerOrderTab5Screen> createState() =>
      _CustomerOrderTab5ScreenState();
}

class _CustomerOrderTab5ScreenState extends State<CustomerOrderTab5Screen> {
  final _userRepository = UserRepository();

  bool _isSubmitting = false;
  double _walletBalance = 0.0;
  bool _walletLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }



  Future<void> _loadWalletBalance() async {
    try {
      final me = await _userRepository.getMe();
      if (me != null && mounted) {
        setState(() {
          _walletBalance = me.walletBalance;
          widget.orderRequest.creditApplied = _walletBalance;
          _walletLoaded = true;
        });
      } else if (mounted) {
        setState(() => _walletLoaded = true);
      }
    } catch (_) {
      if (mounted) setState(() => _walletLoaded = true);
    }
  }

  Future<void> _onConfirmOrder() async {
    try {
      if (_isSubmitting) return;
      _isSubmitting = true;
      setState(() {});

      final user = await AuthService().getCurrentUser();
      final customerId = user?.id ?? 'customer_default';
      final profId =
          widget.orderRequest.selectedProfessional?.id ?? 'prof_default';
      final date = widget.orderRequest.scheduledDate ?? DateTime.now();
      final hour = widget.orderRequest.scheduledTimeSlot;

      final catId = widget.orderRequest.selectedCategory?.id ?? '';
      final srvId = widget.orderRequest.selectedServices.isNotEmpty
          ? widget.orderRequest.selectedServices.first.id
          : '';

      try {
        final me = await UserRepository().getMe();
        if (me != null && me.walletBalance > 0) {
          if (me.walletBalance >= widget.orderRequest.creditApplied) {
            widget.orderRequest.creditApplied = me.walletBalance;
          }
          setState(() => _walletBalance = me.walletBalance);
        }
      } catch (_) {}

      final amountToPay = widget.orderRequest.amountToPay;
      final remainingCredit = widget.orderRequest.remainingCredit;
      final isFullyCovered = amountToPay <= 0;


      Object data = {
        "professionalId": profId,
        "customerId": customerId,
        "date": date.toIso8601String(),
        "hour": hour,
        "categoryId": catId,
        "serviceId": srvId,
        "address": widget.orderRequest.address,
        "description": widget.orderRequest.description,
        "notes": widget.orderRequest.notes,
        "photoUrls": widget.orderRequest.photoPaths,
        "totalPrice": widget.price,
        if (isFullyCovered) "status": "PendingAcceptance",
      };

      final appointment = await AppointmentRepository().create(data);

      if (appointment == null || appointment.id.isEmpty) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Falha ao registrar solicitação. Verifique sua conexão e tente novamente.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      final appointmentId = appointment.id;

      if (isFullyCovered) {
        // Debitar o valor total da carteira no backend
        await UserRepository().debitWallet(
          widget.orderRequest.servicePrice,
          reason: 'Pagamento de agendamento via saldo em carteira',
        );

        // Se sobrou crédito (crédito > preço), já está no wallet — o debit acima cobre só o servicePrice
        if (remainingCredit > 0) {
          // O remainingCredit NÃO precisa ser creditado, pois o wallet só foi debitado pelo servicePrice.
          // O saldo restante permanece no wallet automaticamente.
        }

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitação enviada! O profissional será notificado.',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.primaryGold,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CustomerOrderTab7Screen(
              orderRequest: widget.orderRequest,
              appointmentId: appointmentId,
              price: widget.price,
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

      final paymentId =
          paymentData?['id']?.toString() ??
          paymentData?['_id']?.toString() ??
          paymentData?['asaasId']?.toString() ??
          '';
      final qrCodeImage =
          paymentData?['qrCodeImage']?.toString() ??
          paymentData?['qr_code_image']?.toString() ??
          '';
      final qrCodePayload =
          paymentData?['qrCodePayload']?.toString() ??
          paymentData?['qr_code_payload']?.toString() ??
          '';

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (paymentData == null || qrCodePayload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Falha ao gerar cobrança PIX no Asaas. Tente novamente.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CustomerOrderTab6Screen(
            appointmentId: appointmentId,
            orderRequest: widget.orderRequest,
            paymentId: paymentId,
            qrCodeImage: qrCodeImage,
            qrCodePayload: qrCodePayload,
            price: widget.price,
          ),
        ),
      );
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);

    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_walletLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    final prof = widget.orderRequest.selectedProfessional;
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final dateDisplay = widget.orderRequest.scheduledDate != null
        ? DateFormat(
            "dd 'de' MMMM 'de' yyyy",
            'pt_BR',
          ).format(widget.orderRequest.scheduledDate!)
        : 'Hoje, ${DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(DateTime.now())}';

    final servicePrice = widget.orderRequest.servicePrice;
    final creditApplied = widget.orderRequest.creditApplied;
    final amountToPay = widget.orderRequest.amountToPay;
    final remainingCredit = widget.orderRequest.remainingCredit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
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
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                                    style: TextStyle(
                                      color: AppColors.primaryGold,
                                    ),
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
                      const BoraTrampaLogo(
                        size: 34,
                        showSubtitle: false,
                        isHorizontal: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (prof != null)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfessionalProfileScreen(
                              orderRequest: widget.orderRequest,
                              professional: prof,
                              price: prof.basePrice,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cardElevated,
                                      ),
                                      child: ClipOval(
                                        child: prof.avatarUrl.isNotEmpty
                                            ? Image.network(
                                                prof.avatarUrl,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Center(
                                                      child: Text(
                                                        prof.name.isNotEmpty
                                                            ? prof.name[0]
                                                                  .toUpperCase()
                                                            : 'P',
                                                        style:
                                                            GoogleFonts.inter(
                                                              color: AppColors
                                                                  .primaryGold,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ),
                                              )
                                            : Center(
                                                child: Text(
                                                  prof.name.isNotEmpty
                                                      ? prof.name[0]
                                                            .toUpperCase()
                                                      : 'P',
                                                  style: GoogleFonts.inter(
                                                    color:
                                                        AppColors.primaryGold,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                      ),
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
                                          border: Border.all(
                                            color: AppColors.cardBackground,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          Flexible(
                                            child: Text(
                                              prof.name,
                                              style: GoogleFonts.inter(
                                                color: AppColors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: AppColors.primaryGold,
                                            size: 15,
                                          ),
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
                                          const Icon(
                                            Icons.star_rounded,
                                            color: AppColors.primaryGold,
                                            size: 14,
                                          ),
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
                                      'Diária',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      UtilBrasilFields.obterReal(
                                        widget.price,
                                      ),
                                      style: GoogleFonts.inter(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: AppColors.divider),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Visualizar perfil do profissional',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.primaryGold,
                                  size: 12,
                                ),
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
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.primaryGold,
                                size: 18,
                              ),
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
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              UtilBrasilFields.obterReal(widget.price),
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (creditApplied > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (widget.orderRequest.previousAppointmentId?.isNotEmpty ?? false)
                                    ? 'Crédito já pago (anterior)'
                                    : 'Saldo em carteira',
                                style: GoogleFonts.inter(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '- R\$ ${creditApplied.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: GoogleFonts.inter(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
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
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '+ R\$ ${remainingCredit.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: AppColors.divider),
                        ),
                        if (_walletLoaded && _walletBalance > 0 && amountToPay > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Seu saldo (R\$ ${_walletBalance.toStringAsFixed(2).replaceAll('.', ',')}) não é suficiente. '
                                    'O restante de R\$ ${amountToPay.toStringAsFixed(2).replaceAll('.', ',')} será cobrado via PIX.',
                                    style: GoogleFonts.inter(
                                      color: Colors.orange.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              amountToPay > 0
                                  ? 'Diferença a pagar'
                                  : 'Total a pagar agora',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'R\$ ${amountToPay.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                color: amountToPay > 0
                                    ? AppColors.primaryGold
                                    : AppColors.success,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.success,
                              size: 14,
                            ),
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
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 1.5,
                            ),
                            color: const Color(0xFF1E1A10),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
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
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
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
