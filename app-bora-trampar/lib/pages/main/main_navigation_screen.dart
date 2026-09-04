import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../financial/financial_history_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/identity_verification_pending_screen.dart';
import '../onboarding/professional_onboarding_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  bool _isCheckingAccess = true;
  bool _isProfessional = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _verifyAccess();
  }

  Future<void> _verifyAccess() async {
    final user = await AuthService().getCurrentUser();
    final role = (user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');

    if (isPro) {
      ProfileProfessionalModel? profile;
      if (user != null && user.id.isNotEmpty) {
        profile = await ProfileProfessionalRepository().getByUserId(user.id);
      }
      profile ??= await ProfileProfessionalRepository().getMe();

      if (!mounted) return;

      if (profile == null || !profile.isProfileCompleted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfessionalOnboardingScreen()),
          (route) => false,
        );
        return;
      }

      final status = profile.identityVerificationStatus.toLowerCase();
      if (status != 'approved') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => IdentityVerificationPendingScreen(initialProfile: profile)),
          (route) => false,
        );
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isProfessional = isPro;
        _isCheckingAccess = false;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    final pages = [
      HomeScreen(
        onNavigateToSchedule: () => _onTabSelected(1),
        onNavigateToProfile: () => _onTabSelected(3),
      ),
      ScheduleScreen(
        onNavigateToProfile: () => _onTabSelected(3),
      ),
      FinancialHistoryScreen(
        onNavigateToProfile: () => _onTabSelected(3),
      ),
      const ProfileScreen(),
    ];

    final proNavItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month_rounded),
        label: 'Agenda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Financeiro',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Perfil',
      ),
    ];

    final customerNavItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore_rounded),
        label: 'Explorar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment_rounded),
        label: 'Meus Pedidos',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.credit_card_outlined),
        activeIcon: Icon(Icons.credit_card_rounded),
        label: 'Pagamentos',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Minha Conta',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
            items: _isProfessional ? proNavItems : customerNavItems,
          ),
        ),
      ),
    );
  }
}
