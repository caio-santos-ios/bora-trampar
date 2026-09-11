import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/main_app_bar.dart';
import '../../../models/appointment_model.dart';
import '../../../models/payment_model.dart';
import '../../../repositories/appointment/appointment_repository.dart';
import '../../../repositories/payment/payment_repository.dart';

class ProfessionalFinancialHistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const ProfessionalFinancialHistoryScreen({
    super.key,
    this.onNavigateToProfile,
  });

  @override
  State<ProfessionalFinancialHistoryScreen> createState() =>
      _ProfessionalFinancialHistoryScreenState();
}

class _ProfessionalFinancialHistoryScreenState
    extends State<ProfessionalFinancialHistoryScreen> {
  final PaymentRepository _paymentRepo = PaymentRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  bool _isLoading = true;
  bool _hideBalance = false;
  List<PaymentModel> _payments = [];
  List<AppointmentModel> _appointments = [];
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final payments = await _paymentRepo.getPayments();
    final appointments = await _appointmentRepo.getAppointments();

    if (mounted) {
      setState(() {
        _payments = payments
            .where((p) => p.appointmentStatus == "FinishProfessional")
            .toList();
        _appointments = appointments;
        _isLoading = false;
      });
    }
  }

  double get _totalRevenue {
    return _appointments
        .where((a) {
          return a.status == "Finish";
        })
        .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
  }

  double get _monthRevenue {
    final now = DateTime.now();
    return _appointments
        .where((a) {
          final isThisMonth =
              a.date.year == now.year && a.date.month == now.month;
          return isThisMonth && a.status == "Finish";
        })
        .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
  }

  int get _completedCount {
    return _appointments.where((a) {
      return a.status == "Finish";
    }).length;
  }

  double get _pendingRevenue {
    return _appointments
        .where((a) {
          return a.status == "FinishProfessional";
        })
        .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
  }

  List<PaymentModel> get _filteredPayments {
    if (_selectedFilterIndex == 0) return _payments;
    final filter = ['', 'pago', 'pend'][_selectedFilterIndex];
    return _payments
        .where((p) => (p.status ?? '').toLowerCase().contains(filter))
        .toList();
  }

  String _normalizeStatusPaymentName(String status) {
    switch (status.toUpperCase()) {
      case "RECEIVED-FINISH":
        return "Pago";
      case "RECEIVED-FINISHPROFESSIONAL":
        return "Pendente";
      case "PENDING":
        return "Pendente";
      case "EXPENSE":
        return "Reembolso";
      default:
        return "";
    }
  }

  Color _normalizeStatusPaymentColor(String status) {
    switch (status.toUpperCase()) {
      case "RECEIVED-FINISH":
        return AppColors.primaryGold;
      case "RECEIVED-FINISHPROFESSIONAL":
        return Colors.yellowAccent;
      case "EXPENSE":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _normalizeStatusName(String status) {
    switch (status) {
      case "Finish":
        return "Recebido";
      case "FinishProfessional":
        return "Aguardando Receber";
      case "PendingPayment":
        return "Pagamento Pendente";
      case "PendingAcceptance":
        return "Aguardando Profissional Aceitar";
      case "Accepted":
        return "Você Confirmou";
      case "Declined":
        return "Você Recusou";
      case "StartService":
        return "Você Iniciou Serviço";
      case "CancelledByCustomer":
        return "Cliente Cancelou";
      default:
        return "";
    }
  }

  Color _normalizeStatusColor(String status) {
    switch (status) {
      case "Finish":
      case "Accepted":
        return Colors.green;
      case "PendingPayment":
      case "FinishProfessional":
        return Colors.orangeAccent;
      case "PendingAcceptance":
        return Colors.blueAccent;
      case "StartService":
        return Colors.purpleAccent;
      case "Declined":
      case "CancelledByCustomer":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Financeiro',
        onProfileTap: widget.onNavigateToProfile,
      ),
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
              : _buildProfessionalView(),
        ),
      ),
    );
  }

  Widget _buildProfessionalView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            gradient: const RadialGradient(
              center: Alignment(0.8, -0.6),
              radius: 1.2,
              colors: [Color(0xFF2B2514), Color(0xFF141414)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Recebido (todos os tempos)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _hideBalance = !_hideBalance),
                    child: Icon(
                      _hideBalance
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _hideBalance
                    ? '••••••'
                    : UtilBrasilFields.obterReal(_totalRevenue),
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryStat(
                    label: 'Este Mês',
                    value: _hideBalance
                        ? '••••'
                        : UtilBrasilFields.obterReal(_monthRevenue),
                    valueColor: AppColors.success,
                  ),
                  _buildSummaryStat(
                    label: 'A Receber (pendente)',
                    value: _hideBalance
                        ? '••••'
                        : UtilBrasilFields.obterReal(_pendingRevenue),
                    valueColor: AppColors.primaryGold,
                  ),
                  _buildSummaryStat(
                    label: 'Concluídos',
                    value: '$_completedCount diária(s)',
                    valueColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_appointments.isNotEmpty) ...[
          Text(
            'Resumo por Mês',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMonthlyBreakdown(),
          const SizedBox(height: 24),
        ],
        Text(
          'Receitas',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_appointments.isEmpty)
          _buildEmptyState(
            'Nenhuma transação encontrada.',
            'Os agendamentos aparecerão aqui ao serem registrados.',
          )
        else
          ..._appointments
              .where((a) => a.price != null && a.price! > 0)
              .toList()
              .map((a) {
                String st = a.status;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionCard(
                    title: a.serviceName ?? a.categoryName ?? 'Serviço',
                    partyName: a.customerName?.isNotEmpty == true
                        ? 'Cliente: ${a.customerName}'
                        : 'Cliente não identificado',
                    date: DateFormat(
                      "dd/MM/yyyy '•' HH:mm",
                      'pt_BR',
                    ).format(a.date),
                    paymentMethod: '',
                    amount: UtilBrasilFields.obterReal(a.price!),
                    status: _normalizeStatusName(a.status),
                    statusColor: _normalizeStatusColor(a.status),
                    isIncome: st == "Finish",
                    hasIsIncome: st != "FinishProfessional",
                  ),
                );
              }),
        const SizedBox(height: 24),
        if (_payments
            .where(
              (e) => e.status == "RECEIVED" && e.appointmentStatus == "Finish",
            )
            .isNotEmpty) ...[
          Text(
            'Histórico de Recebimentos',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._payments
              .where(
                (e) =>
                    e.status == "RECEIVED" && e.appointmentStatus == "Finish",
              )
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionCard(
                    title: p.title ?? "Recebimento",
                    partyName: p.partyName ?? '',
                    date: DateFormat(
                      "dd/MM/yyyy '•' HH:mm",
                      'pt_BR',
                    ).format(p.date),
                    paymentMethod: p.methodPayment,
                    amount: UtilBrasilFields.obterReal(p.value),
                    status: _normalizeStatusPaymentName(
                      "${p.status ?? ""}-${p.appointmentStatus ?? ""}",
                    ),
                    statusColor: _normalizeStatusPaymentColor(
                      "${p.status ?? ""}-${p.appointmentStatus ?? ""}",
                    ),
                    isIncome: true,
                    hasIsIncome: true
                  ),
                ),
              ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthlyBreakdown() {
    final Map<String, double> byMonth = {};
    for (final a in _appointments) {
      if (a.price == null || a.price! <= 0) continue;
      final s = a.status.toLowerCase();
      if (s != 'completed' &&
          s != 'finished' &&
          s != 'concluido' &&
          s != 'accepted' &&
          s != 'confirmed')
        continue;
      final key = DateFormat('MMM/yyyy', 'pt_BR').format(a.date);
      byMonth[key] = (byMonth[key] ?? 0) + (a.price ?? 0);
    }

    if (byMonth.isEmpty) return const SizedBox.shrink();

    return Column(
      children: byMonth.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                _hideBalance ? '••••' : UtilBrasilFields.obterReal(entry.value),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String partyName,
    required String date,
    required String paymentMethod,
    required String amount,
    required String status,
    required Color statusColor,
    required bool isIncome,
    required bool hasIsIncome
  }) {
    
    return Container(
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
              color: !hasIsIncome ? AppColors.cardElevated : isIncome
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.cardElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: !hasIsIncome ? AppColors.cardElevated : isIncome
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              !hasIsIncome ? Icons.lock_clock_outlined : isIncome
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: !hasIsIncome ? AppColors.primaryGold : isIncome ? AppColors.success : AppColors.primaryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (partyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    partyName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  paymentMethod.isNotEmpty ? '$date • $paymentMethod' : date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${!hasIsIncome ? '=' : isIncome ? '+' : '-'} $amount',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isIncome ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
