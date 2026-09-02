import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../data/models/auth/user_model.dart';
import '../onboarding/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sair da Conta',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja encerrar a sua sessão no aplicativo?',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Sair',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: MainAppBar(title: 'Perfil'),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        ),
      );
    }

    final isCustomer = (_user?.role ?? '').toLowerCase() != 'profissional';
    final name = _user?.name.isNotEmpty == true ? _user!.name : 'Usuário Bora Trampa';
    final email = _user?.email.isNotEmpty == true ? _user!.email : 'usuario@boratrampa.com';
    final whatsApp = _user?.whatsapp?.isNotEmpty == true ? _user!.whatsapp! : '(11) 99999-9999';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: 'Perfil'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold, width: 2.5),
                      color: AppColors.cardElevated,
                    ),
                    child: ClipOval(
                      child: _user?.photo != null && _user!.photo!.isNotEmpty
                          ? Image.network(
                              _user!.photo!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackAvatar(initial),
                            )
                          : _buildFallbackAvatar(initial),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.textDark,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCustomer ? Icons.person_outline : Icons.verified_rounded,
                      color: AppColors.primaryGold,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCustomer ? 'Perfil Cliente' : 'Profissional Verificado',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Dados Pessoais',
                    subtitle: whatsApp,
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildProfileTile(
                    icon: Icons.verified_user_outlined,
                    title: isCustomer ? 'Verificação de Conta' : 'Documentos e Aprovação',
                    subtitle: 'Status: Verificado',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildProfileTile(
                    icon: Icons.payment_outlined,
                    title: 'Formas de Pagamento',
                    subtitle: 'PIX e Cartões cadastrados',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Central de Ajuda',
                    subtitle: 'Perguntas frequentes e suporte',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildProfileTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Termos e Privacidade',
                    subtitle: 'Políticas de uso do Bora Trampa',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 18),
                label: Text(
                  'Sair da Conta',
                  style: GoogleFonts.inter(
                    color: AppColors.errorRed,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.errorRed, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(
          color: AppColors.primaryGold,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1C12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGold, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
    );
  }
}
