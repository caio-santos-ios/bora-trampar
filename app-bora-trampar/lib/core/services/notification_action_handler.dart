import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage_service.dart';

/// Handler chamado em isolate separado quando usuario toca num botao de acao
/// da notificacao sem abrir o app (showsUserInterface: false).
///
/// Deve ser funcao top-level anotada com @pragma('vm:entry-point').
@pragma('vm:entry-point')
void onNotificationActionBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final appointmentId = response.payload ?? '';

  // Cancela a notificacao imediatamente para sumir da barra
  try {
    if (response.id != null) {
      final localNotifications = FlutterLocalNotificationsPlugin();
      await localNotifications.cancel(id: response.id!);
    }
  } catch (_) {}

  if (appointmentId.isEmpty) return;
  if (actionId != 'accept_appointment' && actionId != 'decline_appointment') return;

  try {
    String token = '';
    try {
      await Hive.initFlutter();
      if (!Hive.isBoxOpen(StorageService.boxName)) {
        await Hive.openBox(StorageService.boxName);
      }
      token = StorageService.getToken();
    } catch (_) {}

    final endpoint = actionId == 'accept_appointment'
        ? '/api/appointments/$appointmentId/accept'
        : '/api/appointments/$appointmentId/decline';

    final dio = Dio(BaseOptions(
      baseUrl: 'https://bora-trampar.onrender.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    await dio.put(endpoint);
  } catch (_) {}
}