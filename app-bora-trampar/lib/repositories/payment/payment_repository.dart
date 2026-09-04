import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';
import '../../models/payment_model.dart';

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
          'appointmentId': appointmentId,
          'appointment_id': appointmentId,
          'value': value,
          'methodPayment': 'PIX Instantâneo',
          'method_payment': 'PIX Instantâneo',
          'date': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic res = response.data['result'] ?? response.data['data'] ?? response.data;
        if (res is Map && res['data'] != null && res['data'] is Map) {
          return Map<String, dynamic>.from(res['data'] as Map);
        }
        if (res is Map<String, dynamic>) {
          return res;
        }
        if (res is Map) {
          return Map<String, dynamic>.from(res);
        }
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<({bool success, String message})> confirmPayment(String paymentId) async {
    try {
      final response = await _api.client.post('/api/payments/confirm/$paymentId');
      if (response.statusCode == 200) {
        return (success: true, message: 'Pagamento Aprovado pelo Asaas! O profissional foi notificado.');
      }
      return (success: false, message: 'Pagamento ainda não confirmado.');
    } on DioException catch (e) {
      final msg = e.response?.data?['result']?['message']?.toString() ??
          e.response?.data?['message']?.toString() ??
          'O pagamento via PIX ainda não foi identificado pelo Asaas. Se você já pagou ou simulou no sandbox, aguarde alguns segundos e tente novamente.';
      return (success: false, message: msg);
    } catch (_) {
      return (success: false, message: 'Erro ao verificar pagamento.');
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
