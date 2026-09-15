import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:app_bora_trampar/pages/onboarding/welcome_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UtilService {
  static void normalizeError(BuildContext context, DioException err) {
    if (err.response == null) {
      Toastfy.show(context, "Falha interna", "error");
    } else {
      int status = err.response?.statusCode ?? 400;
      if (status == 401) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      }

      if (err.response != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(err.response?.data);

        String message = "";

        if(data.containsKey("errors")) {
          List<String> errors = (data["errors"] as List).map((e) => e["message"].toString()).toList();
          message = errors[0];
        } else {
          message = err.response?.data["message"];
        }

        Toastfy.show(
          context,
          message,
          status > 204 ? "warning" : "success",
        );
      }
    }
  }
}
