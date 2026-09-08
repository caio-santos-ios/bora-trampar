import 'package:dio/dio.dart';
import '../../api/http_client_api.dart';

class AddressResultModel {
  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final double? latitude;
  final double? longitude;

  AddressResultModel({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.latitude,
    this.longitude,
  });

  factory AddressResultModel.fromJson(Map<String, dynamic> json) {
    return AddressResultModel(
      cep: (json['cep'] ?? json['zipCode'] ?? '').toString(),
      street: (json['street'] ?? json['logradouro'] ?? '').toString(),
      neighborhood: (json['neighborhood'] ?? json['bairro'] ?? '').toString(),
      city: (json['city'] ?? json['localidade'] ?? '').toString(),
      state: (json['state'] ?? json['uf'] ?? '').toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'cep': cep,
    'street': street,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class AddressRepository {
  final HttpClientApi _api = HttpClientApi();

  Future<AddressResultModel?> getAddressByCep(String rawCep) async {
    final cleanCep = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    try {
      final response = await _api.client.get('/api/addresses/$cleanCep');
      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['result'] ?? response.data;
        final data = result is Map ? (result['data'] ?? result) : response.data;
        if (data is Map) {
          return AddressResultModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {
      // Fallback para BrasilAPI v2 caso ocorra instabilidade de rede na API interna
      try {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 6),
            receiveTimeout: const Duration(seconds: 6),
          ),
        );
        final bApiRes = await dio.get(
          'https://brasilapi.com.br/api/cep/v2/$cleanCep',
        );
        if (bApiRes.statusCode == 200 &&
            bApiRes.data is Map &&
            bApiRes.data['type'] != 'service_error') {
          final loc = bApiRes.data['location'];
          final coords = loc is Map ? loc['coordinates'] as Map? : null;
          final lat = double.tryParse(coords?['latitude']?.toString() ?? '');
          final lon = double.tryParse(coords?['longitude']?.toString() ?? '');
          return AddressResultModel(
            cep: cleanCep,
            street: bApiRes.data['street']?.toString() ?? '',
            neighborhood: bApiRes.data['neighborhood']?.toString() ?? '',
            city: bApiRes.data['city']?.toString() ?? '',
            state: bApiRes.data['state']?.toString() ?? '',
            latitude: lat,
            longitude: lon,
          );
        }
      } catch (_) {}
    }
    return null;
  }
}
