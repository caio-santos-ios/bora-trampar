import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification/notification_repository.dart';
import '../../repositories/appointment/appointment_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'Serviços', 'Pagamentos'];

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  final Map<String, String> _appointmentActionStatus = {};
  final Set<String> _processingActionIds = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repository.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(AppNotification item) async {
    if (item.read) return;
    final success = await _repository.markAsRead(item.id);
    if (success && mounted) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: item.id,
            type: item.type,
            title: item.title,
            message: item.message,
            read: true,
            createdAt: item.createdAt,
          );
        }
      });
    }
  }

  Future<void> _handleAcceptAppointment(AppNotification item) async {
    final appointmentId = item.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) return;
    if (_processingActionIds.contains(appointmentId)) return;

    setState(() => _processingActionIds.add(appointmentId));
    final success = await _appointmentRepository.acceptAppointment(appointmentId);
    if (mounted) {
      setState(() {
        _processingActionIds.remove(appointmentId);
        if (success) {
          _appointmentActionStatus[appointmentId] = 'accepted';
        }
      });
      _markAsRead(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Agendamento aceito com sucesso!' : 'Falha ao aceitar agendamento.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: success ? AppColors.textDark : Colors.white),
          ),
          backgroundColor: success ? AppColors.primaryGold : AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _handleDeclineAppointment(AppNotification item) async {
    final appointmentId = item.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) return;
    if (_processingActionIds.contains(appointmentId)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rejeitar Agendamento', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Tem certeza de que deseja recusar este agendamento?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Sim, recusar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processingActionIds.add(appointmentId));
    final success = await _appointmentRepository.declineAppointment(appointmentId);
    if (mounted) {
      setState(() {
        _processingActionIds.remove(appointmentId);
        if (success) {
          _appointmentActionStatus[appointmentId] = 'declined';
        }
      });
      _markAsRead(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Agendamento recusado.' : 'Falha ao recusar agendamento.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          backgroundColor: success ? AppColors.errorRed : AppColors.cardBorder,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadList = _notifications.where((n) => !n.read).toList();
    for (final item in unreadList) {
      await _repository.markAsRead(item.id);
    }
    _loadNotifications();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
      case 'pagamentos':
        return Icons.account_balance_wallet_outlined;
      case 'service':
      case 'serviços':
        return Icons.calendar_today_rounded;
      case 'review':
        return Icons.star_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours} hora(s)';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedFilterIndex == 0
        ? _notifications
        : _notifications.where((n) {
            final filter = _filters[_selectedFilterIndex].toLowerCase();
            final type = n.type.toLowerCase();
            if (filter == 'serviços') return type == 'service' || type == 'serviço' || type == 'serviços';
            if (filter == 'pagamentos') return type == 'payment' || type == 'pagamento' || type == 'pagamentos';
            return true;
          }).toList();

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
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllAsRead,
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGold),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppColors.primaryGold,
                      child: filteredNotifications.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                Center(
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
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredNotifications.length,
                              separatorBuilder: (_, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filteredNotifications[index];
                                final isUnread = !item.read;

                                return InkWell(
                                  onTap: () => _markAsRead(item),
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
                                            _getIconForType(item.type),
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
                                                      item.title,
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
                                                const SizedBox(height: 6),
                                                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                                  Container(
                                                    margin: const EdgeInsets.only(bottom: 6),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryGold.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.handyman_rounded, size: 14, color: AppColors.primaryGold),
                                                        const SizedBox(width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            item.subtitle!,
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.primaryGold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                if (item.message.isNotEmpty && item.message != item.subtitle)
                                                  Text(
                                                    item.message,
                                                    style: GoogleFonts.inter(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 13,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                if (item.appointmentId != null && item.appointmentId!.isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Builder(
                                                    builder: (context) {
                                                      final aptId = item.appointmentId!;
                                                      final status = _appointmentActionStatus[aptId];
                                                      final isProcessing = _processingActionIds.contains(aptId);

                                                      if (status == 'accepted') {
                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.success.withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                                                              const SizedBox(width: 6),
                                                              Text(
                                                                'Agendamento Aceito',
                                                                style: GoogleFonts.inter(
                                                                  color: AppColors.success,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }

                                                      if (status == 'declined') {
                                                        return Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.errorRed.withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.cancel_rounded, size: 14, color: AppColors.errorRed),
                                                              const SizedBox(width: 6),
                                                              Text(
                                                                'Agendamento Recusado',
                                                                style: GoogleFonts.inter(
                                                                  color: AppColors.errorRed,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }

                                                      if (isProcessing) {
                                                        return const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 4),
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: AppColors.primaryGold,
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      return Row(
                                                        children: [
                                                          Expanded(
                                                            child: OutlinedButton.icon(
                                                              onPressed: () => _handleDeclineAppointment(item),
                                                              icon: const Icon(Icons.close_rounded, size: 15, color: AppColors.errorRed),
                                                              label: Text(
                                                                'Rejeitar',
                                                                style: GoogleFonts.inter(
                                                                  color: AppColors.errorRed,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                              style: OutlinedButton.styleFrom(
                                                                side: const BorderSide(color: AppColors.errorRed, width: 1.2),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: ElevatedButton.icon(
                                                              onPressed: () => _handleAcceptAppointment(item),
                                                              icon: const Icon(Icons.check_rounded, size: 15, color: AppColors.textDark),
                                                              label: Text(
                                                                'Aceitar',
                                                                style: GoogleFonts.inter(
                                                                  color: AppColors.textDark,
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w800,
                                                                ),
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.primaryGold,
                                                                foregroundColor: AppColors.textDark,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(height: 6),
                                                ],
                                                const SizedBox(height: 6),
                                                Text(
                                                  _formatRelativeTime(item.createdAt),
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
            ),
          ],
        ),
      ),
    );
  }
}
