import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/profile/profile_professional_model.dart';
import '../../data/repositories/profile/profile_professional_repository.dart';
import '../main/main_navigation_screen.dart';
import 'professional_onboarding_screen.dart';
import 'welcome_screen.dart';

class IdentityVerificationPendingScreen extends StatefulWidget {
  final ProfileProfessionalModel? initialProfile;

  const IdentityVerificationPendingScreen({
    super.key,
    this.initialProfile,
  });

  @override
  State<IdentityVerificationPendingScreen> createState() => _IdentityVerificationPendingScreenState();
}

class _IdentityVerificationPendingScreenState extends State<IdentityVerificationPendingScreen> {
  final ProfileProfessionalRepository _profileRepo = ProfileProfessionalRepository();
  bool _isChecking = false;
  late ProfileProfessionalModel? _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    final updated = await _profileRepo.getMe();

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      if (updated != null) _profile = updated;
    });

    final status = (_profile?.identityVerificationStatus ?? 'pending').toLowerCase().trim();

    if (status == 'approved' || status == 'approve') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Parabéns! Sua identidade foi verificada com sucesso.',
            style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else if (status == 'rejected' || status == 'reject') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sua documentação foi recusada. Verifique o motivo abaixo e reenvie.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } else if (status == 'correction') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sua documentação necessita de correção. Por favor, ajuste os dados solicitados.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seu cadastro ainda está em análise pela equipe de moderação.',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.cardBackground,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (_profile?.identityVerificationStatus ?? 'pending').toLowerCase().trim();
    final isApproved = status == 'approved' || status == 'approve';
    final isRejected = status == 'rejected' || status == 'reject';
    final isCorrection = status == 'correction';

    Color badgeColor = AppColors.primaryGold;
    String badgeText = 'EM ANÁLISE';
    IconData statusIcon = Icons.hourglass_top_rounded;
    String screenTitle = 'Validação de Identidade';

    if (isApproved) {
      badgeColor = AppColors.success;
      badgeText = 'APROVADO';
      statusIcon = Icons.verified_rounded;
      screenTitle = 'Cadastro Aprovado';
    } else if (isRejected) {
      badgeColor = AppColors.errorRed;
      badgeText = 'CADASTRO REPROVADO';
      statusIcon = Icons.cancel_outlined;
      screenTitle = 'Documentação Recusada';
    } else if (isCorrection) {
      badgeColor = Colors.orangeAccent;
      badgeText = 'NECESSITA CORREÇÃO';
      statusIcon = Icons.edit_note_rounded;
      screenTitle = 'Ajuste de Documentação';
    }

    final reason = _profile?.identityVerificationNotes.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const BoraTrampaLogo(size: 42),
              const SizedBox(height: 32),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor.withValues(alpha: 0.12),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 2),
                ),
                child: Center(
                  child: Icon(
                    statusIcon,
                    size: 46,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                screenTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isRejected
                    ? 'Infelizmente sua documentação não foi aceita pela equipe de moderação.'
                    : isCorrection
                        ? 'Sua documentação precisa de correções para que possamos liberar seu acesso.'
                        : 'Seus dados e documentos de identificação estão sendo analisados pela nossa equipe de moderação. Os menus e agendamentos serão liberados assim que seu cadastro for aprovado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (isRejected || isCorrection) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isRejected ? Icons.report_problem_rounded : Icons.info_outline_rounded,
                            color: badgeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRejected ? 'Motivo da Reprovação:' : 'Orientações da Moderação:',
                            style: GoogleFonts.inter(
                              color: badgeColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (reason != null && reason.isNotEmpty)
                            ? reason
                            : 'Documentação ilegível ou divergente dos dados cadastrais fornecidos.',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Documento Registrado',
                      value: '${_profile?.identityDocumentType ?? "CNH"} • ${_profile?.identityDocumentNumber.isNotEmpty == true ? _profile!.identityDocumentNumber : "Cadastrado"}',
                    ),
                    const Divider(color: AppColors.cardBorder, height: 24),
                    _buildInfoRow(
                      icon: Icons.photo_library_outlined,
                      label: 'Fotos Enviadas',
                      value: 'Frente, Verso e Selfie com Documento',
                    ),
                    const Divider(color: AppColors.cardBorder, height: 24),
                    _buildInfoRow(
                      icon: Icons.security_rounded,
                      label: 'Segurança BoraTrampar',
                      value: 'Garantia de autenticidade e conformidade',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (isRejected || isCorrection) ...[
                PrimaryButton(
                  text: 'Corrigir e Reenviar Cadastro',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfessionalOnboardingScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                        )
                      : const Icon(Icons.refresh_rounded, color: AppColors.primaryGold, size: 18),
                  label: Text(
                    'Verificar Novamente',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.primaryGold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Verificar Status da Aprovação',
                  isLoading: _isChecking,
                  onPressed: _checkStatus,
                ),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted, size: 18),
                label: Text(
                  'Sair da Conta',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
