import 'dart:convert';
import 'package:app_bora_trampar/api/http_client_api.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_7_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../models/order_request_model.dart';
import 'package:signalr_netcore/signalr_client.dart';

class CustomerOrderTab6Screen extends StatefulWidget {
  final OrderRequestModel orderRequest;
  final String appointmentId;
  final String paymentId;
  final String qrCodeImage;
  final String qrCodePayload;

  const CustomerOrderTab6Screen({
    super.key,
    required this.orderRequest,
    required this.appointmentId,
    required this.paymentId,
    required this.qrCodeImage,
    required this.qrCodePayload,
  });

  @override
  State<CustomerOrderTab6Screen> createState() =>
      _CustomerOrderTab6ScreenState();
}

class _CustomerOrderTab6ScreenState extends State<CustomerOrderTab6Screen> {
  late HubConnection _connection;
  final _httpClientApi = HttpClientApi();

  @override
  void initState() {
    super.initState();
    _setupSignalR();
  }

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }

  Future<void> _setupSignalR() async {
    try {
      _connection = HubConnectionBuilder()
          .withUrl('${_httpClientApi.baseUrl}/hubs/appointment')
          .withAutomaticReconnect()
          .build();

      _connection.on('AppointmentUpdated', (arguments) async {
        final data = arguments![0] as Map;
        if (data['status'] == 'Received' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Pagamento Confirmado com sucesso!",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CustomerOrderTab7Screen(
                  orderRequest: widget.orderRequest,
                  appointmentId: widget.appointmentId,
                ),
              ),
            );
          }
        }
      });

      await _connection.start();
      debugPrint(
        'SignalR conectado! Confirmar Pagamento: ${_connection.state}',
      );

      await _connection.invoke(
        'JoinAppointmentGroup',
        args: [widget.appointmentId],
      );
    } catch (e) {
      debugPrint('ERRO ao conectar SignalR: $e');
    }
  }

  Future<void> _copyPixCode() async {
    await Clipboard.setData(ClipboardData(text: widget.qrCodePayload));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código PIX Copia e Cola copiado com sucesso!',
            style: GoogleFonts.inter(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );
    }
  }

  Widget _buildQrImage() {
    if (widget.qrCodeImage.startsWith('data:image')) {
      try {
        final base64String = widget.qrCodeImage.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 190,
          height: 190,
          fit: BoxFit.contain,
        );
      } catch (_) {
        return const SizedBox(
          width: 190,
          height: 190,
          child: Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 100,
              color: Colors.black87,
            ),
          ),
        );
      }
    }

    if (widget.qrCodeImage.isNotEmpty &&
        widget.qrCodeImage.startsWith('http')) {
      return Image.network(
        widget.qrCodeImage,
        width: 190,
        height: 190,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          width: 190,
          height: 190,
          child: Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 100,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    return const SizedBox(
      width: 190,
      height: 190,
      child: Center(
        child: Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prof = widget.orderRequest.selectedProfessional;
    final total = widget.orderRequest.totalPrice;
    final formattedDate = widget.orderRequest.scheduledDate != null
        ? DateFormat(
            "dd/MM/yyyy",
            'pt_BR',
          ).format(widget.orderRequest.scheduledDate!)
        : 'Hoje';

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
          'Pagamento Seguro',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: BoraTrampaLogo(
              size: 28,
              showSubtitle: false,
              isHorizontal: false,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.cardElevated,
                    backgroundImage: prof != null
                        ? NetworkImage(prof.avatarUrl)
                        : null,
                    child: prof == null
                        ? const Icon(Icons.person, color: AppColors.primaryGold)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prof?.name ?? 'Profissional Especialista',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.orderRequest.serviceNamesDisplay,
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$formattedDate • ${widget.orderRequest.scheduledTimeSlot}',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primaryGold,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pague com PIX via Asaas',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Abra o app do seu banco e escaneie o código abaixo.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder, width: 2),
                    ),
                    child: _buildQrImage(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _copyPixCode,
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primaryGold,
                        size: 18,
                      ),
                      label: Text(
                        'Copiar código PIX',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Aguardando confirmação do banco...',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seu dinheiro fica protegido pela Bora Trampar até a finalização do serviço.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // PrimaryButton(
            //   text: _isProcessing
            //       ? 'Confirmando...'
            //       : 'Confirmar Pagamento Realizado',
            //   onPressed: _isProcessing ? null : _confirmPayment,
            // ),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
