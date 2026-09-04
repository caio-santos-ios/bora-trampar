import 'dart:convert';
import 'package:app_bora_trampar/models/profile_professional_model.dart';
import 'package:app_bora_trampar/pages/main/main_navigation_screen.dart';
import 'package:app_bora_trampar/pages/onboarding/identity_verification_pending_screen.dart';
import 'package:app_bora_trampar/pages/onboarding/professional_onboarding_screen.dart';
import 'package:app_bora_trampar/repositories/auth/auth_repository.dart';
import 'package:app_bora_trampar/repositories/profile/profile_professional_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../customer/customer_register_screen.dart';
import 'forgot_password_screen.dart';
import '../professional/professional_register_screen.dart';
import 'package:app_bora_trampar/core/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  final String initialRole;

  const LoginScreen({super.key, this.initialRole = 'Profissional'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _profileProfessionalRepository = ProfileProfessionalRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isLoading = true);

      final response = await _authRepository.login({
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": widget.initialRole,
      });

      final result = response.data["result"];
      final resultData = result is Map ? (result["data"] ?? result) : response.data;
      final token = (resultData is Map ? (resultData["token"] ?? resultData["data"]?["token"]) : null)?.toString() ?? '';
      final refreshToken = (resultData is Map ? (resultData["refreshToken"] ?? resultData["data"]?["refreshToken"]) : null)?.toString();
      final rawUser = resultData is Map ? (resultData["user"] ?? resultData["data"]?["user"]) : null;

      Map<String, dynamic>? userMap;
      if (rawUser is Map) {
        userMap = Map<String, dynamic>.from(rawUser);
        if (userMap["role"] == null || userMap["role"].toString().isEmpty) {
          userMap["role"] = widget.initialRole;
        }
      }

      if (token.isNotEmpty) {
        await StorageService.setToken(token);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await StorageService.setRefreshToken(refreshToken);
        }
        if (userMap != null) {
          await StorageService.setUser(userMap);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', refreshToken);
        }
        if (userMap != null) {
          await prefs.setString('user_profile', jsonEncode(userMap));
        }
      }

      if (widget.initialRole == "Customer") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login realizado com sucesso!',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        bool isProfileCompleted = (resultData is Map ? (resultData["isProfileCompleted"] ?? resultData["data"]?["isProfileCompleted"]) : null) ?? false;

        if (!isProfileCompleted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfessionalOnboardingScreen(),
            ),
            (route) => false,
          );
          return;
        }

        final userObj = resultData is Map ? (resultData["user"] ?? resultData["data"]?["user"]) : null;
        String useridentityVerificationStatusId = (userObj is Map ? userObj["identityVerificationStatus"] : null)?.toString() ?? '';

        if (useridentityVerificationStatusId == "Approved") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login realizado com sucesso!',
                style: GoogleFonts.inter(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
            (route) => false,
          );
        } else {
          String userId = (userObj is Map ? userObj["id"] : null)?.toString() ?? '';

          ProfileProfessionalModel? profile =
              await _profileProfessionalRepository.getByUserId(userId);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  IdentityVerificationPendingScreen(initialProfile: profile),
            ),
            (route) => false,
          );
        }
      }
    } on DioException {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.initialRole == 'Customer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: BoraTrampaLogo(size: 48)),
                const SizedBox(height: 28),
                Text(
                  isCustomer ? 'Login de Cliente' : 'Login de Profissional',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCustomer
                      ? 'Entre com suas credenciais para contratar serviços e acompanhar pedidos.'
                      : 'Entre com suas credenciais para gerenciar suas diárias e agendamentos.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'E-mail',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'seuemail@exemplo.com',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu e-mail.';
                    }
                    if (!value.contains('@')) {
                      return 'Informe um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Senha',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.inputBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Esqueceu a senha?',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Entrar na Conta',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => isCustomer
                              ? const CustomerRegisterScreen()
                              : const ProfessionalRegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: isCustomer
                                ? 'Não tem conta de cliente? '
                                : 'Não tem conta profissional? ',
                          ),
                          TextSpan(
                            text: 'Cadastre-se',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
