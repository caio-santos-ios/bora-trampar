import 'package:dio/dio.dart';
import '../../../api/http_client_api.dart';
import '../../models/payment/payment_model.dart';

class PaymentRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<PaymentModel>> getPayments() async {
    try {
      final response = await _api.client.get('/api/payments');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is List) {
          return res.map((item) => PaymentModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final response = await _api.client.get('/api/payments/$id');

      if (response.statusCode == 200 && response.data != null) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null) {
          res = res['data'];
        }
        if (res is Map<String, dynamic>) {
          return PaymentModel.fromJson(res);
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> createAsaasPixPayment({
    required String appointmentId,
    required double value,
    required String customerName,
  }) async {
    try {
      final response = await _api.client.post(
        '/api/payments/asaas/pix',
        data: {
          'appointment_id': appointmentId,
          'value': value,
          'method_payment': 'PIX Instantâneo',
          'date': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map<String, dynamic>) {
          return res;
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> confirmPayment(String paymentId) async {
    try {
      final response = await _api.client.post('/api/payments/confirm/$paymentId');
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createPayment({
    required String methodPayment,
    required DateTime date,
    required double value,
    String appointmentId = '',
  }) async {
    try {
      final response = await _api.client.post(
        '/api/payments',
        data: {
          'method_payment': methodPayment,
          'date': date.toIso8601String(),
          'value': value,
          'appointment_id': appointmentId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
