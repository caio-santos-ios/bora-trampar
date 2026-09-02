import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../data/models/appointment/appointment_model.dart';
import '../../data/models/payment/payment_model.dart';
import '../../data/repositories/appointment/appointment_repository.dart';
import '../../data/repositories/payment/payment_repository.dart';

class FinancialHistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const FinancialHistoryScreen({super.key, this.onNavigateToProfile});

  @override
  State<FinancialHistoryScreen> createState() => _FinancialHistoryScreenState();
}

class _FinancialHistoryScreenState extends State<FinancialHistoryScreen> {
  final PaymentRepository _paymentRepo = PaymentRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  bool _isLoading = true;
  bool _isProfessional = false;
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
    final user = await AuthService().getCurrentUser();
    final role = (user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');

    final payments = await _paymentRepo.getPayments();
    final appointments = await _appointmentRepo.getAppointments();

    if (mounted) {
      setState(() {
        _isProfessional = isPro;
        _payments = payments;
        _appointments = appointments;
        _isLoading = false;
      });
    }
  }

  double get _totalRevenue {
    if (_isProfessional) {
      return _appointments
          .where((a) {
            final s = a.status.toLowerCase();
            return s == 'completed' || s == 'finished' || s == 'concluido' || s == 'accepted' || s == 'confirmed';
          })
          .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
    }
    return _payments.fold(0.0, (sum, p) => sum + p.value);
  }

  double get _monthRevenue {
    final now = DateTime.now();
    if (_isProfessional) {
      return _appointments
          .where((a) {
            final s = a.status.toLowerCase();
            final isThisMonth = a.date.year == now.year && a.date.month == now.month;
            return isThisMonth && (s == 'completed' || s == 'finished' || s == 'concluido' || s == 'accepted' || s == 'confirmed');
          })
          .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
    }
    return _payments
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0.0, (sum, p) => sum + p.value);
  }

  int get _completedCount {
    if (_isProfessional) {
      return _appointments.where((a) {
        final s = a.status.toLowerCase();
        return s == 'completed' || s == 'finished' || s == 'concluido';
      }).length;
    }
    return _payments.length;
  }

  double get _pendingRevenue {
    if (_isProfessional) {
      return _appointments
          .where((a) {
            final s = a.status.toLowerCase();
            return s == 'pending' || s == 'paid' || s == 'requested' || s == 'pendingpayment';
          })
          .fold(0.0, (sum, a) => sum + (a.price ?? 0.0));
    }
    return _payments
        .where((p) => (p.status ?? '').toLowerCase().contains('pend'))
        .fold(0.0, (sum, p) => sum + p.value);
  }

  List<PaymentModel> get _filteredPayments {
    if (_selectedFilterIndex == 0) return _payments;
    final filter = ['', 'pago', 'pend'][_selectedFilterIndex];
    return _payments.where((p) => (p.status ?? '').toLowerCase().contains(filter)).toList();
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: _isProfessional ? 'Financeiro' : 'Pagamentos',
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
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _hideBalance = !_hideBalance),
                    child: Icon(
                      _hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _hideBalance ? '••••••' : _formatCurrency(_totalRevenue),
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
                    value: _hideBalance ? '••••' : _formatCurrency(_monthRevenue),
                    valueColor: AppColors.success,
                  ),
                  _buildSummaryStat(
                    label: 'A Receber (pendente)',
                    value: _hideBalance ? '••••' : _formatCurrency(_pendingRevenue),
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
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildMonthlyBreakdown(),
          const SizedBox(height: 24),
        ],
        Text(
          'Agendamentos e Receitas',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (_appointments.isEmpty)
          _buildEmptyState('Nenhuma transação encontrada.', 'Os agendamentos aparecerão aqui ao serem registrados.')
        else
          ..._appointments
              .where((a) => a.price != null && a.price! > 0)
              .toList()
              .map((a) {
                final st = a.status.toLowerCase();
                final String statusDisplay;
                final Color statusColor;

                if (st == 'completed' || st == 'finished' || st == 'concluido') {
                  statusDisplay = 'Concluído';
                  statusColor = AppColors.success;
                } else if (st == 'accepted' || st == 'confirmed') {
                  statusDisplay = 'Confirmado';
                  statusColor = AppColors.primaryGold;
                } else if (st == 'declined' || st == 'cancelled' || st == 'canceled') {
                  statusDisplay = 'Cancelado';
                  statusColor = AppColors.errorRed;
                } else {
                  statusDisplay = 'Pendente';
                  statusColor = AppColors.textMuted;
                }

                final isReceived = st == 'completed' || st == 'finished' || st == 'concluido' || st == 'accepted' || st == 'confirmed';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionCard(
                    title: a.serviceName ?? a.categoryName ?? 'Serviço',
                    partyName: a.customerName?.isNotEmpty == true ? 'Cliente: ${a.customerName}' : 'Cliente não identificado',
                    date: DateFormat("dd/MM/yyyy '•' HH:mm", 'pt_BR').format(a.date),
                    paymentMethod: '',
                    amount: _formatCurrency(a.price!),
                    status: statusDisplay,
                    statusColor: statusColor,
                    isIncome: isReceived,
                  ),
                );
              }),
        const SizedBox(height: 24),
        if (_payments.isNotEmpty) ...[
          Text(
            'Histórico de Pagamentos',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ..._payments.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionCard(
                  title: p.title ?? 'Recebimento',
                  partyName: p.partyName ?? '',
                  date: DateFormat("dd/MM/yyyy '•' HH:mm", 'pt_BR').format(p.date),
                  paymentMethod: p.methodPayment,
                  amount: _formatCurrency(p.value),
                  status: p.status ?? 'Registrado',
                  statusColor: AppColors.success,
                  isIncome: true,
                ),
              )),
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
      if (s != 'completed' && s != 'finished' && s != 'concluido' && s != 'accepted' && s != 'confirmed') continue;
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
                  const Icon(Icons.calendar_month_rounded, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    entry.key,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                _hideBalance ? '••••' : _formatCurrency(entry.value),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomerView() {
    final filters = ['Todos', 'Pagos', 'Pendentes'];

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
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _hideBalance = !_hideBalance),
                          child: Icon(
                            _hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hideBalance ? '••••••' : _formatCurrency(_totalRevenue),
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
                          value: _hideBalance ? '••••' : _formatCurrency(_monthRevenue),
                          valueColor: AppColors.primaryGold,
                        ),
                        _buildSummaryStat(
                          label: 'Pendente',
                          value: _hideBalance ? '••••' : _formatCurrency(_pendingRevenue),
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
                          color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        selectedColor: AppColors.primaryGold,
                        backgroundColor: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? AppColors.primaryGold : AppColors.cardBorder),
                        ),
                        onSelected: (_) => setState(() => _selectedFilterIndex = index),
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
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: _filteredPayments.isEmpty
              ? _buildEmptyState('Nenhuma transação encontrada.', 'Seus pagamentos realizados aparecerão aqui.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: _filteredPayments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _filteredPayments[index];
                    final st = (p.status ?? '').toLowerCase();
                    final Color statusColor = st.contains('pag') || st.contains('aprov')
                        ? AppColors.success
                        : st.contains('pend')
                            ? AppColors.primaryGold
                            : AppColors.textMuted;

                    return _buildTransactionCard(
                      title: p.title ?? 'Pagamento de Serviço',
                      partyName: p.partyName ?? '',
                      date: DateFormat("dd/MM/yyyy '•' HH:mm", 'pt_BR').format(p.date),
                      paymentMethod: p.methodPayment,
                      amount: _formatCurrency(p.value),
                      status: p.status ?? 'Registrado',
                      statusColor: statusColor,
                      isIncome: false,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat({required String label, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
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
              decoration: const BoxDecoration(color: AppColors.cardBackground, shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
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
              color: isIncome ? AppColors.success.withValues(alpha: 0.12) : AppColors.cardElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isIncome ? AppColors.success.withValues(alpha: 0.4) : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isIncome ? AppColors.success : AppColors.primaryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (partyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(partyName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 2),
                Text(
                  paymentMethod.isNotEmpty ? '$date • $paymentMethod' : date,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
