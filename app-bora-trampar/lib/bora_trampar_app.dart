import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/welcome_screen.dart';

class BoraTrampaApp extends StatelessWidget {
  const BoraTrampaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoraTrampa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}