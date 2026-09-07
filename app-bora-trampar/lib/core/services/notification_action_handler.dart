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

  if (appointmentId.isEmpty) return;
  if (actionId != 'accept_appointment' && actionId != 'decline_appointment') return;

  try {
    // Inicializa Hive para ler o token salvo (necessario no isolate separado)
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(StorageService.boxName)) {
      await Hive.openBox(StorageService.boxName);
    }
    final token = StorageService.getToken();

    final endpoint = actionId == 'accept_appointment'
        ? '/api/appointments/$appointmentId/accept'
        : '/api/appointments/$appointmentId/decline';

    final dio = Dio(BaseOptions(
      baseUrl: 'https://bora-trampar.onrender.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    await dio.put(endpoint);
  } catch (_) {
    // Silencioso: isolate de background nao pode mostrar UI
  }
}