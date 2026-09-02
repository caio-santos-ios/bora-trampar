import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/models/dashboard/dashboard_model.dart';
import '../../data/models/payment/payment_model.dart';
import '../../data/repositories/dashboard/dashboard_repository.dart';
import '../../data/repositories/payment/payment_repository.dart';

class FinancialHistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const FinancialHistoryScreen({super.key, this.onNavigateToProfile});

  @override
  State<FinancialHistoryScreen> createState() => _FinancialHistoryScreenState();
}

class _FinancialHistoryScreenState extends State<FinancialHistoryScreen> {
  final PaymentRepository _paymentRepo = PaymentRepository();
  final DashboardRepository _dashboardRepo = DashboardRepository();

  UserModel? _user;
  DashboardModel? _dashboard;
  List<PaymentModel> _payments = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    final dashboard = await _dashboardRepo.getMetrics();
    final payments = await _paymentRepo.getPayments();

    if (mounted) {
      setState(() {
        _user = user;
        _dashboard = dashboard;
        _payments = payments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = (_user?.role ?? '').toLowerCase() != 'profissional';
    final filters = ['Todos', 'Pagos', 'Pendentes'];

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
          child: ListView(
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
                    colors: [
                      Color(0xFF2B2514),
                      Color(0xFF141414),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCustomer ? 'Total Investido em Serviços' : 'Saldo Total Recebido',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dashboard != null && _dashboard!.totalRevenue > 0
                          ? 'R\$ ${_dashboard!.totalRevenue.toStringAsFixed(2).replaceAll('.', ',')}'
                          : (isCustomer ? 'R\$ 750,00' : 'R\$ 2.450,00'),
                      style: GoogleFonts.inter(
                        fontSize: 28,
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
                          label: isCustomer ? 'Diárias Pagas' : 'Diárias Concluídas',
                          value: _dashboard != null && _dashboard!.monthAppointments > 0
                              ? '${_dashboard!.monthAppointments} diárias'
                              : (isCustomer ? '4 diárias' : '14 diárias'),
                        ),
                        _buildSummaryStat(
                          label: isCustomer ? 'Em Aberto' : 'A Liberar (Garantia)',
                          value: isCustomer ? 'R\$ 220,00' : 'R\$ 440,00',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              Text(
                'Transações Recentes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  ),
                )
              else if (_payments.isNotEmpty)
                ..._payments.map((p) {
                  final dateFormatted = DateFormat("dd/MM/yyyy '•' HH:mm").format(p.date);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTransactionCard(
                      title: p.title ?? (isCustomer ? 'Diária de Serviço' : 'Recebimento de Diária'),
                      partyName: p.partyName ?? (isCustomer ? 'Profissional Designado' : 'Cliente Contratante'),
                      date: dateFormatted,
                      paymentMethod: p.methodPayment,
                      amount: 'R\$ ${p.value.toStringAsFixed(2).replaceAll('.', ',')}',
                      status: p.status ?? 'Aprovado',
                      statusColor: AppColors.success,
                      isIncome: !isCustomer,
                    ),
                  );
                })
              else ...[
                _buildTransactionCard(
                  title: isCustomer ? 'Diária de Construção' : 'Recebimento - Alvenaria',
                  partyName: isCustomer ? 'Profissional: Marcos Silva' : 'Cliente: Roberto Almeida',
                  date: '29/08/2026 • 08:30',
                  paymentMethod: 'PIX Instantâneo',
                  amount: 'R\$ 180,00',
                  status: 'Aprovado',
                  statusColor: AppColors.success,
                  isIncome: !isCustomer,
                ),
                const SizedBox(height: 12),
                _buildTransactionCard(
                  title: isCustomer ? 'Pintura Residencial' : 'Recebimento - Pintura',
                  partyName: isCustomer ? 'Profissional: Carlos Lima' : 'Cliente: Juliana Mendes',
                  date: '24/08/2026 • 15:40',
                  paymentMethod: 'Cartão de Crédito',
                  amount: 'R\$ 220,00',
                  status: 'Aprovado',
                  statusColor: AppColors.success,
                  isIncome: !isCustomer,
                ),
                const SizedBox(height: 12),
                _buildTransactionCard(
                  title: isCustomer ? 'Reparo Elétrico' : 'Recebimento - Elétrica',
                  partyName: isCustomer ? 'Profissional: Rodrigo Santos' : 'Cliente: Lucas Ferreira',
                  date: '20/08/2026 • 11:20',
                  paymentMethod: 'PIX Instantâneo',
                  amount: 'R\$ 150,00',
                  status: 'Concluído',
                  statusColor: AppColors.textMuted,
                  isIncome: !isCustomer,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat({required String label, required String value}) {
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
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
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
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  partyName,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date • $paymentMethod',
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
