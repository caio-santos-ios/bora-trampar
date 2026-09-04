import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../repositories/auth/auth_repository.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthRepository _repository = AuthRepository();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = 'Professional',
  }) async {
    try {
      final normalizedRole = role.toLowerCase().contains('prof') ? 'Professional' : 'Customer';
      final response = await _repository.login({
        'email': email.trim(),
        'password': password,
        'role': normalizedRole,
      });

      final data = response.data as Map<String, dynamic>? ?? {};
      final result = data['result'];
      final token = result is Map ? result['token']?.toString() : null;
      final refreshToken = result is Map ? result['refreshToken']?.toString() : null;
      final userJson = result is Map ? result['user'] : null;

      if (token != null) {
        await _saveSession(token, refreshToken, userJson);
      }

      return {
        'success': true,
        'message': data['message']?.toString() ?? 'Login realizado com sucesso!',
        'user': userJson != null ? UserModel.fromJson(Map<String, dynamic>.from(userJson as Map)) : null,
      };
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg = 'Falha na autenticação.';

      if (errorData is Map) {
        final result = errorData['result'];
        if (errorData['errors'] is List && (errorData['errors'] as List).isNotEmpty) {
          final firstError = (errorData['errors'] as List)[0];
          errorMsg = firstError is Map ? (firstError['message'] ?? firstError['Message'] ?? errorMsg) : firstError.toString();
        } else if (result is Map && result['message'] != null) {
          errorMsg = result['message'].toString();
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['title'] != null) {
          errorMsg = errorData['title'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Aguarde alguns instantes e tente novamente.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        if (e.message!.toLowerCase().contains('timeout')) {
          errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Tente novamente.';
        } else {
          errorMsg = 'Erro de conexão com o servidor. Tente novamente.';
        }
      }

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor. Tente novamente.',
      };
    }
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String whatsApp,
    required String password,
  }) async {
    try {
      final response = await _repository.register({
        'name': name.trim(),
        'email': email.trim(),
        'whatsApp': whatsApp.trim(),
        'password': password,
        'role': 'Customer',
      });

      final data = response.data;

      return {
        'success': true,
        'message': data['message'] ?? 'Conta criada com sucesso! Faça login para continuar.',
      };
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg = 'Falha ao realizar cadastro.';

      if (errorData is Map) {
        if (errorData['errors'] is List && (errorData['errors'] as List).isNotEmpty) {
          final firstError = (errorData['errors'] as List)[0];
          errorMsg = firstError is Map ? (firstError['message'] ?? firstError['Message'] ?? errorMsg) : firstError.toString();
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['title'] != null) {
          errorMsg = errorData['title'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Aguarde alguns instantes e tente novamente.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        if (e.message!.toLowerCase().contains('timeout')) {
          errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Tente novamente.';
        } else {
          errorMsg = 'Erro de conexão com o servidor. Tente novamente.';
        }
      }

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor. Tente novamente.',
      };
    }
  }

  Future<Map<String, dynamic>> registerProfessional({
    required String name,
    required String email,
    required String whatsApp,
    required String password,
  }) async {
    try {
      final response = await _repository.register({
        'name': name.trim(),
        'email': email.trim(),
        'whatsApp': whatsApp.trim(),
        'password': password,
        'role': 'Professional',
      });

      final data = response.data;

      return {
        'success': true,
        'message': data['message'] ?? 'Conta criada com sucesso! Faça login para continuar.',
      };
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMsg = 'Falha ao realizar cadastro.';

      if (errorData is Map) {
        if (errorData['errors'] is List && (errorData['errors'] as List).isNotEmpty) {
          final firstError = (errorData['errors'] as List)[0];
          errorMsg = firstError is Map ? (firstError['message'] ?? firstError['Message'] ?? errorMsg) : firstError.toString();
        } else if (errorData['message'] != null) {
          errorMsg = errorData['message'].toString();
        } else if (errorData['title'] != null) {
          errorMsg = errorData['title'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Aguarde alguns instantes e tente novamente.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        if (e.message!.toLowerCase().contains('timeout')) {
          errorMsg = 'Tempo limite esgotado. O servidor pode estar iniciando. Tente novamente.';
        } else {
          errorMsg = 'Erro de conexão com o servidor. Tente novamente.';
        }
      }

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor. Tente novamente.',
      };
    }
  }

  Future<void> _saveSession(String token, String? refreshToken, dynamic user) async {
    await StorageService.setToken(token);
    if (refreshToken != null) {
      await StorageService.setRefreshToken(refreshToken);
    }
    if (user != null) {
      await StorageService.setUser(user);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    if (user != null) {
      await prefs.setString('user_profile', jsonEncode(user));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final hiveUser = StorageService.getUser();
    if (hiveUser != null) {
      try {
        if (hiveUser is UserModel) {
          return hiveUser;
        }
        if (hiveUser is Map) {
          return UserModel.fromJson(Map<String, dynamic>.from(hiveUser));
        }
        if (hiveUser is String && hiveUser.isNotEmpty) {
          final decoded = jsonDecode(hiveUser);
          if (decoded is Map) {
            return UserModel.fromJson(Map<String, dynamic>.from(decoded));
          }
        }
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_profile');
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      } catch (_) {}
    }
    return null;
  }

  Future<void> logout() async {
    await StorageService.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_profile');
  }
}
