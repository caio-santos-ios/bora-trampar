import 'package:app_bora_trampar/core/theme/app_colors.dart';
import 'package:app_bora_trampar/core/widgets/main_app_bar.dart';
import 'package:app_bora_trampar/models/payment_model.dart';
import 'package:app_bora_trampar/repositories/payment/payment_repository.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomerFinancialScrren extends StatefulWidget {
  const CustomerFinancialScrren({super.key});

  @override
  State<CustomerFinancialScrren> createState() =>
      _CustomerFinancialScrrenState();
}

class _CustomerFinancialScrrenState extends State<CustomerFinancialScrren> {
  final _paymentRepo = PaymentRepository();

  bool _isLoading = true;
  bool _hideBalance = false;
  List<PaymentModel> _payments = [];
  List<PaymentModel> _paymentsFilted = [];
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final payments = await _paymentRepo.getPayments();

    if (mounted) {
      setState(() {
        _payments = payments;
        _paymentsFilted = payments;
        _isLoading = false;
      });
    }
  }

  String _normalizeStatusName(String status) {
    switch (status.toUpperCase()) {
      case "RECEIVED":
        return "Pago";
      case "PENDING":
        return "Pendente";
      case "EXPENSE":
        return "Reembolso";
      default:
        return "";
    }
  }

  Color _normalizeStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "RECEIVED":
        return AppColors.primaryGold;
      case "PENDING":
        return Colors.yellowAccent;
      case "EXPENSE":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double get _totalRevenue {
    return _payments.where((p) => p.status == "RECEIVED").fold(0.0, (sum, p) => sum + p.value);
  }

  double get _monthRevenue {
    final now = DateTime.now();
    return _payments
        .where((p) => p.date.year == now.year && p.date.month == now.month && p.status == "RECEIVED")
        .fold(0.0, (sum, p) => sum + p.value);
  }

  int get _completedCount {
    return _payments.where((p) => p.status == "RECEIVED").length;
  }

  double get _pendingRevenue {
    return _payments.where((p) => p.status == "PENDING").fold(0.0, (sum, p) => sum + p.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Pagamentos',
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
              : _buildCustomerView(),
        ),
      ),
    );
  }

  Widget _buildCustomerView() {
    final filters = ['Todos', 'Pagos', 'Pendentes', 'Reembolsos'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
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
                          'Total Investido em Serviços',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _hideBalance = !_hideBalance),
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
                      _hideBalance ? '••••••' : UtilBrasilFields.obterReal(_totalRevenue),
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
                          valueColor: AppColors.primaryGold,
                        ),
                        _buildSummaryStat(
                          label: 'Pendente',
                          value: _hideBalance
                              ? '••••'
                              : UtilBrasilFields.obterReal(_pendingRevenue),
                          valueColor: AppColors.textMuted,
                        ),
                        _buildSummaryStat(
                          label: 'Diárias Pagas',
                          value: '$_completedCount pagamento(s)',
                          valueColor: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
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
                        onSelected: (_) {
                          setState(() => _selectedFilterIndex = index);
                          setState(() {
                            if(index == 0) {
                              _payments = _paymentsFilted;
                            } else {
                              if(index == 1)  _payments = _paymentsFilted.where((p) => p.status == "RECEIVED").toList();
                              if(index == 2) _payments = _paymentsFilted.where((p) => p.status == "PENDING").toList();
                              if(index == 3) _payments = _paymentsFilted.where((p) => p.status == "EXPENSE").toList();
                            }
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transações',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: _payments.isEmpty
              ? _buildEmptyState(
                  'Nenhuma transação encontrada.',
                  'Seus pagamentos realizados aparecerão aqui.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: _payments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _payments[index];
                   
                    return _buildTransactionCard(
                      title: p.title ?? 'Pagamento de Serviço',
                      partyName: p.partyName ?? '',
                      date: DateFormat(
                        "dd/MM/yyyy '•' HH:mm",
                        'pt_BR',
                      ).format(p.date),
                      paymentMethod: p.methodPayment,
                      amount: UtilBrasilFields.obterReal(p.value),
                      status: p.status ?? "",
                      isIncome: p.status == "EXPENSE",
                    );
                  },
                ),
        ),
      ],
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
    required bool isIncome,
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
              color: isIncome
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.cardElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isIncome
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              Icons.currency_exchange,
              color: isIncome ? AppColors.success : AppColors.primaryGold,
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
                '${isIncome ? '+' : '-'} $amount',
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
                  color: _normalizeStatusColor(status).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _normalizeStatusName(status),
                  style: GoogleFonts.inter(
                    color: Colors.white,
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
