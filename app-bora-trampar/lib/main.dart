import 'package:app_bora_trampar/bora_trampar_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/core/services/notification_service.dart';
import 'package:app_bora_trampar/core/services/notification_action_handler.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  final appointmentId = message.data['appointmentId']?.toString() ?? '';
  final action = message.data['action']?.toString() ?? '';
  final title = message.data['title']?.toString() ??
      message.notification?.title ??
      'Novo Agendamento Recebido!';
  final body = message.data['body']?.toString() ??
      message.notification?.body ??
      '';
  final isNewAppointmentRequest = appointmentId.isNotEmpty &&
      (action == 'new_appointment_request' ||
          title.toLowerCase().contains('novo agendamento'));

  final localNotifications = FlutterLocalNotificationsPlugin();

  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificacoes Importantes',
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveBackgroundNotificationResponse: onNotificationActionBackground,
  );

  final androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'Notificacoes Importantes',
    importance: Importance.high,
    priority: Priority.high,
    actions: isNewAppointmentRequest
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

  await localNotifications.show(
    id: message.hashCode,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(android: androidDetails),
    payload: appointmentId,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('pt_BR', null);
  await StorageService.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService().init();
  } catch (e) {
    debugPrint('[main] Erro ao inicializar Firebase/Notificacoes: $e');
  }

  runApp(const BoraTrampaApp());
}
