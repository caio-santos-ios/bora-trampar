import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_action_handler.dart';
import '../../pages/notifications/notifications_screen.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/notification/notification_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationRepo = NotificationRepository();
  final _appointmentRepo = AppointmentRepository();
  OverlayEntry? _currentBannerEntry;

  Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificações Importantes',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final actionId = response.actionId;
          final appointmentId = response.payload;

          if (appointmentId != null && appointmentId.isNotEmpty) {
            if (actionId == 'accept_appointment') {
              await _handleAcceptAppointment(appointmentId);
              return;
            } else if (actionId == 'decline_appointment') {
              await _handleDeclineAppointment(appointmentId);
              return;
            }
          }

          _navigateToNotifications();
        },
        onDidReceiveBackgroundNotificationResponse: onNotificationActionBackground,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final appointmentId = message.data['appointmentId']?.toString() ?? '';
        final title = notification?.title ?? message.data['title']?.toString() ?? 'Novo Agendamento Recebido!';
        final body = notification?.body ?? message.data['body']?.toString() ?? '';
        final isAppointment = appointmentId.isNotEmpty || (message.data['type']?.toString().toLowerCase() == 'service');

        final androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'Notificações Importantes',
          importance: Importance.high,
          priority: Priority.high,
          actions: isAppointment
              ? const <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    'decline_appointment',
                    'Recusar',
                    cancelNotification: true,
                    showsUserInterface: false,
                  ),
                  AndroidNotificationAction(
                    'accept_appointment',
                    'Aceitar',
                    cancelNotification: true,
                    showsUserInterface: false,
                  ),
                ]
              : null,
        );

        _localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          payload: appointmentId,
          notificationDetails: NotificationDetails(
            android: androidDetails,
          ),
        );

        if (isAppointment) {
          _showInAppAppointmentBanner(
            appointmentId: appointmentId,
            title: title,
            body: body,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _navigateToNotifications();
      });

      // Atualiza token FCM no backend
      syncFcmToken();
    } catch (e) {
      debugPrint('[NotificationService] Erro ao inicializar notificações: $e');
    }
  }

  void _showInAppAppointmentBanner({
    required String appointmentId,
    required String title,
    required String body,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _currentBannerEntry?.remove();
    _currentBannerEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1C16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AppColors.primaryGold, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          entry.remove();
                          if (_currentBannerEntry == entry) {
                            _currentBannerEntry = null;
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                        ),
                      ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            entry.remove();
                            if (_currentBannerEntry == entry) {
                              _currentBannerEntry = null;
                            }
                            if (appointmentId.isNotEmpty) {
                              await _handleDeclineAppointment(appointmentId);
                            }
                          },
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.errorRed),
                          label: Text(
                            'Recusar',
                            style: GoogleFonts.inter(
                              color: AppColors.errorRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.errorRed, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            entry.remove();
                            if (_currentBannerEntry == entry) {
                              _currentBannerEntry = null;
                            }
                            if (appointmentId.isNotEmpty) {
                              await _handleAcceptAppointment(appointmentId);
                            }
                          },
                          icon: const Icon(Icons.check_rounded, size: 16, color: AppColors.textDark),
                          label: Text(
                            'Aceitar',
                            style: GoogleFonts.inter(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.textDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _currentBannerEntry = entry;
    overlayState.insert(entry);

    Future.delayed(const Duration(seconds: 30), () {
      if (_currentBannerEntry == entry) {
        entry.remove();
        _currentBannerEntry = null;
      }
    });
  }

  Future<void> _handleAcceptAppointment(String appointmentId) async {
    try {
      final success = await _appointmentRepo.acceptAppointment(appointmentId);
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Agendamento aceito com sucesso!' : 'Falha ao aceitar agendamento.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: success ? AppColors.textDark : Colors.white),
            ),
            backgroundColor: success ? AppColors.primaryGold : AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] Erro ao aceitar agendamento: $e');
    }
  }

  Future<void> _handleDeclineAppointment(String appointmentId) async {
    try {
      final success = await _appointmentRepo.declineAppointment(appointmentId);
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Agendamento recusado.' : 'Falha ao recusar agendamento.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] Erro ao recusar agendamento: $e');
    }
  }

  void _navigateToNotifications() {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }

  Future<void> syncFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[NotificationService] FCM Token obtido: $token');
        await _notificationRepo.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] Erro ao obter/sincronizar FCM token: $e');
    }
  }
}
