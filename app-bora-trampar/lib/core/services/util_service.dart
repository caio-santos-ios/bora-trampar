// import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:app_bora_trampar/pages/auth/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UtilService {
  // final _storage = StorageService();
  
  static void normalizeError(BuildContext context, DioException err) {
    if (err.response == null) {
      Toastfy.show(context, "Falha interna", "error");
    } else {
      int status = err.response?.statusCode ?? 400;
      if (status == 401) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }

      if (err.response != null) {
        Toastfy.show(
          context,
          err.response?.data["message"],
          status > 204 ? "warning" : "success",
        );
      }
    }
  }

  // static Future<void> normalizeSetToken(Map<String, String> data) async {
  //   await _storage.write(key: "token", value: data["token"]);
  //   await _storage.write(key: "photo", value: data["photo"]);
  //   await _storage.write(key: "name", value: data["name"]);
  //   await _storage.write(key: "admin", value: data["admin"]);
  // }

  // static Future<String> normalizeGetToken() async {
  //   return await _storage.read(key: "token") ?? "";
  // }

  // static Future<void> normalizeCleanToken() async {
  //   await _storage.delete(key: "token");
  //   await _storage.delete(key: "photo");
  // }
}