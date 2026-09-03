import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';
import '../../models/appointment/appointment_model.dart';

class AppointmentRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await _api.client.get('/api/appointments');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          return res.map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      final response = await _api.client.get('/api/appointments/$id');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is Map) {
          return AppointmentModel.fromJson(Map<String, dynamic>.from(res));
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AppointmentModel?> createAppointment({
    required String professionalId,
    required String customerId,
    required DateTime date,
    required String hour,
    String status = 'PendingPayment',
    String categoryId = '',
    String serviceId = '',
    String address = '',
    String description = '',
    String notes = '',
    List<String> photoUrls = const [],
    double totalPrice = 0.0,
  }) async {
    try {
      final response = await _api.client.post(
        '/api/appointments',
        data: {
          'profissionalId': professionalId,
          'profissional_id': professionalId,
          'customerId': customerId,
          'customer_id': customerId,
          'categoryId': categoryId,
          'category_id': categoryId,
          'serviceId': serviceId,
          'service_id': serviceId,
          'date': date.toIso8601String(),
          'hour': hour,
          'status': status,
          'address': address,
          'description': description,
          'notes': notes,
          'photoUrls': photoUrls,
          'photo_urls': photoUrls,
          'totalPrice': totalPrice,
          'total_price': totalPrice,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null && res['data'] is Map) {
          return AppointmentModel.fromJson(Map<String, dynamic>.from(res['data'] as Map));
        }
        if (res is Map<String, dynamic>) {
          return AppointmentModel.fromJson(res);
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> acceptAppointment(String id) async {
    try {
      final response = await _api.client.put('/api/appointments/$id/accept');
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> declineAppointment(String id) async {
    try {
      final response = await _api.client.put('/api/appointments/$id/decline');
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAppointment({
    required String id,
    required String professionalId,
    required String customerId,
    required DateTime date,
    required String hour,
    String status = 'PendingPayment',
  }) async {
    try {
      final response = await _api.client.put(
        '/api/appointments',
        data: {
          'id': id,
          'profissional_id': professionalId,
          'customer_id': customerId,
          'date': date.toIso8601String(),
          'hour': hour,
          'status': status,
        },
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      final response = await _api.client.delete('/api/appointments/$id');
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
