import 'dart:math';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city = '',
    this.state = '',
  });
}

class LocationHelper {
  static Future<LocationResult?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );

      final reverse = await reverseGeocode(position.latitude, position.longitude);

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: reverse?.address ?? 'Minha Localização',
        city: reverse?.city ?? '',
        state: reverse?.state ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<LocationResult?> geocodeAddress(String query) async {
    if (query.trim().isEmpty) return null;

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {'User-Agent': 'BoraTramparApp/1.0'},
        ),
      );

      final cleanCep = query.replaceAll(RegExp(r'\D'), '');
      if (cleanCep.length == 8) {
        try {
          final viaCepRes = await dio.get('https://viacep.com.br/ws/$cleanCep/json/');
          if (viaCepRes.statusCode == 200 && viaCepRes.data is Map && viaCepRes.data['erro'] != true) {
            final street = viaCepRes.data['logradouro']?.toString() ?? '';
            final b = viaCepRes.data['bairro']?.toString() ?? '';
            final c = viaCepRes.data['localidade']?.toString() ?? '';
            final uf = viaCepRes.data['uf']?.toString() ?? '';
            final formatted = [street, b, c, uf].where((s) => s.isNotEmpty).join(', ');
            final searchUrl = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent('$formatted, Brasil')}&limit=1';
            final nomRes = await dio.get(searchUrl);
            if (nomRes.statusCode == 200 && nomRes.data is List && (nomRes.data as List).isNotEmpty) {
              final first = (nomRes.data as List).first;
              return LocationResult(
                latitude: double.tryParse(first['lat']?.toString() ?? '') ?? 0.0,
                longitude: double.tryParse(first['lon']?.toString() ?? '') ?? 0.0,
                address: formatted,
                city: c,
                state: uf,
              );
            }
            return LocationResult(
              latitude: 0.0,
              longitude: 0.0,
              address: formatted,
              city: c,
              state: uf,
            );
          }
        } catch (_) {}
      }

      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1';
      final res = await dio.get(url);
      if (res.statusCode == 200 && res.data is List && (res.data as List).isNotEmpty) {
        final item = (res.data as List).first;
        final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
        final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
        final displayName = item['display_name']?.toString() ?? query;
        return LocationResult(
          latitude: lat,
          longitude: lon,
          address: displayName,
        );
      }

      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        address: query,
      );
    } catch (_) {
      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        address: query,
      );
    }
  }

  static Future<LocationResult?> reverseGeocode(double lat, double lon) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {'User-Agent': 'BoraTramparApp/1.0'},
        ),
      );

      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon';
      final res = await dio.get(url);
      if (res.statusCode == 200 && res.data is Map) {
        final addr = res.data['address'] as Map?;
        final city = addr?['city']?.toString() ?? addr?['town']?.toString() ?? addr?['municipality']?.toString() ?? '';
        final state = addr?['state']?.toString() ?? '';
        final road = addr?['road']?.toString() ?? '';
        final suburb = addr?['suburb']?.toString() ?? addr?['neighbourhood']?.toString() ?? '';
        final display = [road, suburb, city].where((s) => s.isNotEmpty).join(', ');

        return LocationResult(
          latitude: lat,
          longitude: lon,
          address: display.isNotEmpty ? display : (res.data['display_name']?.toString() ?? 'Localização Atual'),
          city: city,
          state: state,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) {
      return 0.0;
    }

    try {
      return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
    } catch (_) {
      const p = 0.017453292519943295;
      final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
          cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }
  }

  static bool isWithinRadius({
    required double customerLat,
    required double customerLon,
    required String customerCity,
    required double proLat,
    required double proLon,
    required String proCity,
    required int radiusKm,
  }) {
    if (customerLat != 0.0 && customerLon != 0.0 && proLat != 0.0 && proLon != 0.0) {
      final dist = calculateDistanceKm(customerLat, customerLon, proLat, proLon);
      return dist <= radiusKm;
    }

    if (customerCity.isNotEmpty && proCity.isNotEmpty) {
      return customerCity.toLowerCase().trim() == proCity.toLowerCase().trim();
    }

    return true;
  }
}
