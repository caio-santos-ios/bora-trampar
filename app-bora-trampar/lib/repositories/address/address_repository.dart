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
    
    final response = await _api.client.get('/api/addresses/$cleanCep');
    return response.statusCode == 200 ? AddressResultModel.fromJson( response.data['result']['data']) : null;
  }

  Future<List<AddressSuggestion>> searchAddresses(String query) async {
    if (query.trim().length < 3) return [];
    final response = await _api.client.get(
      '/api/addresses/search',
      queryParameters: {'q': query},
    );

    return response.statusCode == 200 ? (response.data["result"]["data"] as List).map((e) => AddressSuggestion.fromJson(e)).toList() : [];
  }
}

class AddressSuggestion {
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;

  AddressSuggestion({
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final title = (json['address'] ?? json['name'] ?? '').toString();
    final full = (json['fullAddress'] ?? json['description'] ?? json['formattedAddress'] ?? title).toString();

    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return AddressSuggestion(
      title: title.isNotEmpty ? title : full,
      description: full.isNotEmpty ? full : title,
      latitude: parseCoord(json['lat'] ?? json['latitude']),
      longitude: parseCoord(json['lon'] ?? json['lng'] ?? json['longitude']),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
    );
  }
}

