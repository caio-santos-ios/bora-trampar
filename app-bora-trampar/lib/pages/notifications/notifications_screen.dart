import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'Serviços', 'Pagamentos'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Diária Confirmada!',
      'description': 'Seu agendamento para Pintura Residencial foi confirmado para hoje às 08:00.',
      'time': 'Há 15 minutos',
      'type': 'Serviços',
      'isUnread': true,
      'icon': Icons.calendar_today_rounded,
    },
    {
      'id': '2',
      'title': 'Pagamento em Garantia',
      'description': 'O valor de R\$ 220,00 referente à diária foi reservado com sucesso no Bora Trampa.',
      'time': 'Há 2 horas',
      'type': 'Pagamentos',
      'isUnread': true,
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': '3',
      'title': 'Profissional a Caminho',
      'description': 'Marcos Vinícius informou que está a caminho do local da diária.',
      'time': 'Há 4 horas',
      'type': 'Serviços',
      'isUnread': false,
      'icon': Icons.directions_car_rounded,
    },
    {
      'id': '4',
      'title': 'Avaliação 5 Estrelas',
      'description': 'Você recebeu uma nova avaliação excelente pelo serviço prestado.',
      'time': 'Ontem',
      'type': 'Serviços',
      'isUnread': false,
      'icon': Icons.star_rounded,
    },
    {
      'id': '5',
      'title': 'Transferência Concluída',
      'description': 'O repasse de R\$ 180,00 foi creditado via PIX na sua chave cadastrada.',
      'time': '28/08/2026',
      'type': 'Pagamentos',
      'isUnread': false,
      'icon': Icons.check_circle_outline_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedFilterIndex == 0
        ? _notifications
        : _notifications.where((n) => n['type'] == _filters[_selectedFilterIndex]).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notificações',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_notifications.any((n) => n['isUnread'] == true))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n['isUnread'] = false;
                  }
                });
              },
              child: Text(
                'Ler todas',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
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
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
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
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma notificação',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Você está em dia com todas as suas mensagens.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredNotifications.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredNotifications[index];
                        final isUnread = item['isUnread'] == true;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              item['isUnread'] = false;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUnread ? AppColors.cardElevated : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUnread
                                    ? AppColors.primaryGold.withValues(alpha: 0.4)
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? AppColors.primaryGold.withValues(alpha: 0.15)
                                        : const Color(0xFF1F1C12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: AppColors.primaryGold,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: GoogleFonts.inter(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryGold,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] as String,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['time'] as String,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
