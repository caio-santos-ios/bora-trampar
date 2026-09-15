import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_action_handler.dart';
import '../../pages/notifications/notifications_screen.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/notification/notification_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationRepo = NotificationRepository();
  final _appointmentRepo = AppointmentRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _vibrationTimer;
  OverlayEntry? _currentBannerEntry;

  Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const standardChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notificações Importantes',
        importance: Importance.high,
      );

      const urgentChannel = AndroidNotificationChannel(
        'appointment_requests_channel',
        'Chamados de Serviços',
        description: 'Notificações de novos serviços estilo corrida',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('bora_trampar'),
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(standardChannel);
      await androidPlugin?.createNotificationChannel(urgentChannel);

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
        final action = message.data['action']?.toString() ?? '';
        final title = notification?.title ?? message.data['title']?.toString() ?? 'Novo Agendamento Recebido!';
        final body = notification?.body ?? message.data['body']?.toString() ?? '';
        final isNewAppointmentRequest = appointmentId.isNotEmpty &&
            (action == 'new_appointment_request' ||
                title.toLowerCase().contains('novo agendamento'));

        if (isNewAppointmentRequest) {
          // Quando o aplicativo esta ABERTO, exibe APENAS o modal no topo com as opcoes de Aceitar/Recusar
          _showInAppAppointmentBanner(
            appointmentId: appointmentId,
            title: title,
            body: body,
          );
        } else {
          // Demais notificacoes quando o app esta aberto usam a notificacao padrao
          final androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'Notificações Importantes',
            importance: Importance.high,
            priority: Priority.high,
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
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _navigateToNotifications();
      });

      syncFcmToken();
    } catch (e) {
      debugPrint('[NotificationService] Erro ao inicializar notificaÃ§Ãµes: $e');
    }
  }

  Future<void> _playRideAlert() async {
    try {
      await _stopRideAlert();
      HapticFeedback.heavyImpact();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        HapticFeedback.heavyImpact();
      });

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/bora_trampar.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('[NotificationService] Erro ao tocar som do chamado: $e');
    }
  }

  Future<void> _stopRideAlert() async {
    try {
      _vibrationTimer?.cancel();
      _vibrationTimer = null;
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('[NotificationService] Erro ao parar som do chamado: $e');
    }
  }

  void _showInAppAppointmentBanner({
    required String appointmentId,
    required String title,
    required String body,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _stopRideAlert();
    _currentBannerEntry?.remove();
    _currentBannerEntry = null;

    _playRideAlert();

    late OverlayEntry entry;
    bool isProcessing = false;
    String loadingAction = '';

    entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          if (!isProcessing)
                            GestureDetector(
                              onTap: () {
                                _stopRideAlert();
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
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      _stopRideAlert();
                                      setModalState(() {
                                        isProcessing = true;
                                        loadingAction = 'decline';
                                      });
                                      if (appointmentId.isNotEmpty) {
                                        await _handleDeclineAppointment(appointmentId);
                                      }
                                      entry.remove();
                                      if (_currentBannerEntry == entry) {
                                        _currentBannerEntry = null;
                                      }
                                    },
                              icon: loadingAction == 'decline'
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.errorRed),
                                    )
                                  : const Icon(Icons.close_rounded, size: 16, color: AppColors.errorRed),
                              label: Text(
                                loadingAction == 'decline' ? 'Recusando...' : 'Recusar',
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
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      _stopRideAlert();
                                      setModalState(() {
                                        isProcessing = true;
                                        loadingAction = 'accept';
                                      });
                                      if (appointmentId.isNotEmpty) {
                                        await _handleAcceptAppointment(appointmentId);
                                      }
                                      entry.remove();
                                      if (_currentBannerEntry == entry) {
                                        _currentBannerEntry = null;
                                      }
                                    },
                              icon: loadingAction == 'accept'
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                                    )
                                  : const Icon(Icons.check_rounded, size: 16, color: AppColors.textDark),
                              label: Text(
                                loadingAction == 'accept' ? 'Aceitando...' : 'Aceitar',
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
      },
    );

    _currentBannerEntry = entry;
    overlayState.insert(entry);

    Future.delayed(const Duration(seconds: 30), () {
      if (_currentBannerEntry == entry) {
        _stopRideAlert();
        entry.remove();
        _currentBannerEntry = null;
      }
    });
  }

  Future<void> _handleAcceptAppointment(String appointmentId) async {
    try {
      final success = await _appointmentRepo.acceptAppointment(appointmentId);
      _showActionSnackBar(
        success ? 'Agendamento aceito com sucesso!' : 'Falha ao aceitar agendamento.',
        success ? AppColors.primaryGold : AppColors.errorRed,
        success ? AppColors.textDark : Colors.white,
      );
    } catch (e) {
      _showActionSnackBar(
        'Erro ao processar agendamento.',
        AppColors.errorRed,
        Colors.white,
      );
    }
  }

  Future<void> _handleDeclineAppointment(String appointmentId) async {
    try {
      final success = await _appointmentRepo.declineAppointment(appointmentId);
      _showActionSnackBar(
        success ? 'Agendamento recusado.' : 'Falha ao recusar agendamento.',
        AppColors.errorRed,
        Colors.white,
      );
    } catch (e) {
      _showActionSnackBar(
        'Erro ao recusar agendamento.',
        AppColors.errorRed,
        Colors.white,
      );
    }
  }

  void _showActionSnackBar(String message, Color background, Color textColor) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textColor),
            ),
            backgroundColor: background,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textColor),
              ),
              backgroundColor: background,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
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
        await _notificationRepo.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] Erro ao obter/sincronizar FCM token: $e');
    }
  }
}

