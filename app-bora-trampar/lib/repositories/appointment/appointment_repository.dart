import '../../api/http_client_api.dart';
import '../../models/appointment_model.dart';

class AppointmentRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<List<AppointmentModel>> getAppointments({String query = ""}) async {
    final response = await _api.client.get('/api/appointments?$query');
    return response.statusCode == 200
        ? (response.data["result"]["data"] as List)
              .map((e) => AppointmentModel.fromJson(e))
              .toList()
        : [];
  }

  Future<AppointmentModel?> getAppointmentById(String id) async {
    final response = await _api.client.get('/api/appointments/$id');
    return response.statusCode == 200
        ? AppointmentModel.fromJson(response.data['result']['data'])
        : null;
  }

  Future<AppointmentModel?> create(Object body) async {
    final response = await _api.client.post('/api/appointments', data: body);

    return response.statusCode == 201
        ? AppointmentModel.fromJson(response.data["result"]["data"])
        : null;
  }

  Future<bool> acceptAppointment(String id) async {
    final response = await _api.client.put('/api/appointments/$id/accept');

    return response.statusCode == 200;
  }

  Future<bool> declineAppointment(String id) async {
    final response = await _api.client.put('/api/appointments/$id/decline');
    return response.statusCode == 200;
  }

  Future<bool> startAppointment(String id) async {
    final response = await _api.client.put('/api/appointments/$id/start');
    return response.statusCode == 200;
  }

  Future<bool> finishAppointment(String id) async {
    final response = await _api.client.put('/api/appointments/$id/finish');
    return response.statusCode == 200;
  }

  Future<bool> updateAppointment({
    required String id,
    required String professionalId,
    required String customerId,
    required DateTime date,
    required String hour,
    String status = 'PendingPayment',
  }) async {
    final response = await _api.client.put(
      '/api/appointments',
      data: {
        'id': id,
        'professional_id': professionalId,
        'customer_id': customerId,
        'date': date.toIso8601String(),
        'hour': hour,
        'status': status,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteAppointment(String id) async {
    final response = await _api.client.delete('/api/appointments/$id');
    return response.statusCode == 200;
  }

  Future<bool> cancelByCustomer(String id) async {
    final response = await _api.client.put(
      '/api/appointments/$id/cancel-by-customer',
    );
    return response.statusCode == 200;
  }
}
