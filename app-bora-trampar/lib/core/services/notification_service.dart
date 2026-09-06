import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../repositories/notification/notification_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationRepo = NotificationRepository();

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
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Notificações Importantes',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Callback para quando usuário toca na notificação e app abre
      });

      // Atualiza token FCM no backend
      syncFcmToken();
    } catch (e) {
      debugPrint('[NotificationService] Erro ao inicializar notificações: $e');
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
