import 'package:flutter/material.dart';

class Toastfy {
  static void show(BuildContext context, String message, String type) {
    MaterialColor colors = Colors.green;

    if(type == "success") {
      colors = Colors.green;
    }

    if(type == "warning") {
      colors = Colors.orange;
    }

    if(type == "error") {
      colors = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight(700)
        ),),
        backgroundColor: colors,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}