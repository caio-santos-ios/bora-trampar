import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../main/main_navigation_screen.dart';
import '../onboarding/identity_verification_pending_screen.dart';
import '../onboarding/professional_onboarding_screen.dart';
import '../onboarding/welcome_screen.dart';
import '../../core/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final _profileProfessionalRepository = ProfileProfessionalRepository();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    try {
      String refreshToken = StorageService.getRefreshToken();

      if (refreshToken.isEmpty) {
        _goToWelcome();
        return;
      }

      final response = await _authRepository.refreshToken({
        "refreshToken": refreshToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data["result"];
        final resultData = result["data"];
        final newToken = resultData["token"].toString();
        final newRefreshToken = resultData["refreshToken"].toString();
        final rawUser =  resultData["user"];        

        if (newToken.isNotEmpty) {
          await StorageService.setToken(newToken);
          if (newRefreshToken.isNotEmpty) {
            await StorageService.setRefreshToken(newRefreshToken);
          }

          Map<String, dynamic>? userMap;
          if (rawUser is Map) {
            userMap = Map<String, dynamic>.from(rawUser);
            await StorageService.setUser(userMap);
          }

          NotificationService().syncFcmToken();

          final role = userMap?["role"]?.toString() ?? "Customer";
          final identityVerificationStatus =
              userMap?["identityVerificationStatus"]?.toString() ?? "";
          final isProfileCompleted =
              userMap?["isProfileCompleted"]?.toString() == "true";

          if (!mounted) return;

          if (role.toLowerCase() == "customer") {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
          } else {
            if (!mounted) return;

            if (!isProfileCompleted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const ProfessionalOnboardingScreen(),
                ),
                (route) => false,
              );
            } else if (identityVerificationStatus.toLowerCase() != 'approved') {
              String userId = userMap?["id"] ?? '';

              ProfileProfessionalModel? profile =
                  await _profileProfessionalRepository.getByUserId(userId);

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => IdentityVerificationPendingScreen(
                    initialProfile: profile,
                  ),
                ),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
                (route) => false,
              );
            }
          }
          return;
        }
      }

      await _clearSessionAndGoWelcome();
    } catch (e) {
      if (!_tryNavigateWithLocalSession()) {
        await _clearSessionAndGoWelcome();
      }
    }
  }

  bool _tryNavigateWithLocalSession() {
    if (!mounted) return false;
    final rawUser = StorageService.getUser();
    final token = StorageService.getToken();
    if (token.isEmpty || rawUser == null) return false;

    Map<String, dynamic>? userMap;
    if (rawUser is Map) {
      userMap = Map<String, dynamic>.from(rawUser);
    } else if (rawUser is String) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map) userMap = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    if (userMap == null) return false;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
    return true;
  }

  Future<void> _clearSessionAndGoWelcome() async {
    await StorageService.clear();
    _goToWelcome();
  }

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BoraTrampaLogo(size: 86, isHorizontal: false),
              const SizedBox(height: 48),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
