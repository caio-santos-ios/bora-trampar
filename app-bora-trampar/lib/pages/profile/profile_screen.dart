import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../models/user_model.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/upload/upload_repository.dart';
import '../../repositories/user/user_repository.dart';
import '../onboarding/welcome_screen.dart';
import 'edit_professional_profile_screen.dart';
import 'edit_working_hours_screen.dart';
import 'documents_verification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  ProfileProfessionalModel? _proProfile;
  bool _isLoading = true;
  bool _isProfessional = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    final role = (user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');

    ProfileProfessionalModel? proProfile;
    if (isPro) {
      proProfile = await ProfileProfessionalRepository().getMe();
    }

    if (mounted) {
      setState(() {
        _user = user;
        _isProfessional = isPro;
        _proProfile = proProfile;
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
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Text(
            'Tem certeza de que deseja encerrar a sua sessão?',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Sair', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Excluir Conta',
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza de que deseja excluir permanentemente sua conta? Todos os seus dados, histórico e perfil serão removidos e essa ação não pode ser desfeita.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Excluir Definitivamente', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );

      final success = await UserRepository().deleteAccount(_user!.id);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // fecha loading
      }

      if (success) {
        await AuthService().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sua conta foi excluída com sucesso.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível excluir a conta. Tente novamente mais tarde.',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (_user == null || _isUploadingPhoto) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escolha a origem da foto',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: const Text(
                    'Câmera',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: const Text(
                    'Galeria',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      final uploadedUrl = await UploadRepository().uploadImage(
        File(picked.path),
        folder: 'avatars',
      );

      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Falha ao enviar a foto. Tente novamente.',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      final success = await UserRepository().updatePhoto(_user!.id, uploadedUrl);
      if (success) {
        final updatedUser = _user!.copyWith(photo: uploadedUrl);

        await StorageService.setUser(updatedUser.toJson());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', jsonEncode(updatedUser.toJson()));

        if (mounted) {
          setState(() {
            _user = updatedUser;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Foto de perfil atualizada com sucesso!',
                style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primaryGold,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível salvar a foto no perfil.',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ocorreu um erro ao atualizar a foto.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: _isProfessional ? 'Meu Perfil' : 'Minha Conta',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : _isProfessional
                  ? _buildProfessionalProfile()
                  : _buildCustomerProfile(),
        ),
      ),
    );
  }

  Widget _buildProfessionalProfile() {
    final name = _user?.name.isNotEmpty == true ? _user!.name : 'Profissional';
    final email = _user?.email ?? '';
    final whatsapp = _user?.whatsapp ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final profession = _proProfile?.profession ?? '';
    final bio = _proProfile?.bio ?? '';
    final rating = _proProfile?.rating ?? 0.0;
    final reviewCount = _proProfile?.reviewCount ?? 0;
    final completedCount = _proProfile?.completedServicesCount ?? 0;
    final experienceYears = _proProfile?.experienceYears ?? 0;
    final services = _proProfile?.services ?? [];
    final workingHours = _proProfile?.workingHours ?? [];
    final address = _proProfile?.address;
    final verificationStatus = (_proProfile?.identityVerificationStatus ?? 'Pending').toLowerCase();
    final verificationNotes = _proProfile?.identityVerificationNotes ?? '';
    final isVerified = verificationStatus == 'approved' || verificationStatus == 'verified';
    final isRejected = verificationStatus == 'rejected' || verificationStatus == 'reproved';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildAvatarStack(initial),
        const SizedBox(height: 14),
        Center(
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        if (profession.isNotEmpty) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(
              profession,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.success.withValues(alpha: 0.15)
                  : isRejected
                      ? AppColors.errorRed.withValues(alpha: 0.15)
                      : AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isVerified
                    ? AppColors.success.withValues(alpha: 0.4)
                    : isRejected
                        ? AppColors.errorRed.withValues(alpha: 0.4)
                        : AppColors.primaryGold.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified
                      ? Icons.verified_rounded
                      : isRejected
                          ? Icons.cancel_rounded
                          : Icons.hourglass_top_rounded,
                  color: isVerified
                      ? AppColors.success
                      : isRejected
                          ? AppColors.errorRed
                          : AppColors.primaryGold,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isVerified
                      ? 'Profissional Verificado'
                      : isRejected
                          ? 'Verificação Reprovada'
                          : 'Verificação Pendente',
                  style: GoogleFonts.inter(
                    color: isVerified
                        ? AppColors.success
                        : isRejected
                            ? AppColors.errorRed
                            : AppColors.primaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_rounded,
                value: rating > 0 ? rating.toStringAsFixed(1) : '--',
                label: 'Avaliação',
                iconColor: AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline_rounded,
                value: '$completedCount',
                label: 'Concluídos',
                iconColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.reviews_rounded,
                value: '$reviewCount',
                label: 'Avaliações',
                iconColor: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (isRejected && verificationNotes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.errorRed, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motivo da Reprovação',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.errorRed),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verificationNotes,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (bio.isNotEmpty) ...[
          _buildSection(
            title: 'Sobre Mim',
            child: Text(bio, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 16),
        ],
        _buildSection(
          title: 'Informações de Contato',
          child: Column(
            children: [
              if (email.isNotEmpty) _buildInfoRow(Icons.email_outlined, email),
              if (whatsapp.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone_outlined, whatsapp),
              ],
              if (experienceYears > 0) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.work_history_outlined, '$experienceYears ano(s) de experiência'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (address != null && address.city.isNotEmpty) ...[
          _buildSection(
            title: 'Área de Atendimento',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.location_on_outlined,
                  [address.city, address.state].where((s) => s.isNotEmpty).join(', '),
                ),
                if (address.serviceRadiusKm > 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.radar_rounded, 'Raio de atendimento: ${address.serviceRadiusKm} km'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (services.isNotEmpty) ...[
          _buildSection(
            title: 'Meus Serviços (${services.length})',
            child: Column(
              children: services.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.serviceName.isNotEmpty ? s.serviceName : s.categoryName,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            if (s.categoryName.isNotEmpty && s.serviceName.isNotEmpty)
                              Text(s.categoryName, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Text(
                        s.price > 0 ? 'R\$ ${s.price.toStringAsFixed(2).replaceAll('.', ',')} / ${s.priceType}' : s.priceType,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (workingHours.isNotEmpty) ...[
          _buildSection(
            title: 'Horários de Trabalho',
            child: Column(
              children: workingHours.where((w) => w.isActive).map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        w.dayName.isNotEmpty ? w.dayName : 'Dia ${w.dayOfWeek}',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${w.startHour} – ${w.endHour}',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildMenuSection(isProfessional: true),
        const SizedBox(height: 20),
        _buildLogoutButton(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCustomerProfile() {
    final name = _user?.name.isNotEmpty == true ? _user!.name : 'Usuário';
    final email = _user?.email ?? '';
    final whatsapp = _user?.whatsapp ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildAvatarStack(initial),
        const SizedBox(height: 14),
        Center(
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(email, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
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
                const Icon(Icons.person_outline_rounded, color: AppColors.primaryGold, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Perfil Cliente',
                  style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (email.isNotEmpty || whatsapp.isNotEmpty) ...[
          _buildSection(
            title: 'Meus Dados',
            child: Column(
              children: [
                if (email.isNotEmpty) _buildInfoRow(Icons.email_outlined, email),
                if (whatsapp.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: whatsapp));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'WhatsApp copiado!',
                            style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.primaryGold,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: _buildInfoRow(Icons.phone_outlined, whatsapp, trailing: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildMenuSection(isProfessional: false),
        const SizedBox(height: 20),
        _buildLogoutButton(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildMenuSection({required bool isProfessional}) {
    final tiles = isProfessional
        ? [
            (Icons.edit_outlined, 'Editar Perfil Profissional', 'Profissão, bio e serviços', false),
            (Icons.schedule_outlined, 'Horários de Disponibilidade', 'Dias e horários de atendimento', false),
            (Icons.verified_user_outlined, 'Documentos e Verificação', 'Status de aprovação de identidade', false),
            (Icons.help_outline_rounded, 'Central de Ajuda', 'Dúvidas e suporte', false),
            (Icons.lock_outline_rounded, 'Termos e Privacidade', 'Políticas de uso do Bora Trampar', false),
            (Icons.delete_forever_outlined, 'Excluir Conta', 'Encerrar e apagar seus dados permanentemente', true),
          ]
        : [
            (Icons.person_outline_rounded, 'Dados Pessoais', 'Nome, telefone e endereço', false),
            (Icons.payment_outlined, 'Formas de Pagamento', 'PIX e cartões cadastrados', false),
            (Icons.help_outline_rounded, 'Central de Ajuda', 'Dúvidas e suporte', false),
            (Icons.lock_outline_rounded, 'Termos e Privacidade', 'Políticas de uso do Bora Trampar', false),
            (Icons.delete_forever_outlined, 'Excluir Conta', 'Encerrar e apagar seus dados permanentemente', true),
          ];

    return Material(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(tiles.length, (index) {
          final (icon, title, subtitle, isDestructive) = tiles[index];
          return Column(
            children: [
              ListTile(
                onTap: () async {
                  if (title == 'Excluir Conta') {
                    _handleDeleteAccount();
                  } else if (title == 'Editar Perfil Profissional' && _user != null) {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditProfessionalProfileScreen(
                          user: _user!,
                          proProfile: _proProfile,
                        ),
                      ),
                    );
                    if (updated == true) {
                      _loadData();
                    }
                  } else if (title == 'Horários de Disponibilidade' && _user != null) {
                    final currentPro = _proProfile ??
                        ProfileProfessionalModel(
                          userId: _user!.id,
                          profession: '',
                          bio: '',
                          address: ProfessionalAddressModel(
                            location: ProfessionalAddressLocationModel.empty(),
                          ),
                        );
                    final updated = await Navigator.of(context).push<dynamic>(
                      MaterialPageRoute(
                        builder: (_) => EditWorkingHoursScreen(
                          proProfile: currentPro,
                        ),
                      ),
                    );
                    if (updated is ProfileProfessionalModel) {
                      setState(() => _proProfile = updated);
                    }
                    if (updated != null) {
                      await _loadData();
                    }
                  } else if (title == 'Documentos e Verificação' && _user != null) {
                    final currentPro = _proProfile ??
                        ProfileProfessionalModel(
                          userId: _user!.id,
                          profession: '',
                          bio: '',
                          address: ProfessionalAddressModel(
                            location: ProfessionalAddressLocationModel.empty(),
                          ),
                        );
                    final updated = await Navigator.of(context).push<dynamic>(
                      MaterialPageRoute(
                        builder: (_) => DocumentsVerificationScreen(
                          proProfile: currentPro,
                        ),
                      ),
                    );
                    if (updated is ProfileProfessionalModel) {
                      setState(() => _proProfile = updated);
                    }
                    if (updated != null) {
                      await _loadData();
                    }
                  }
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.errorRed.withValues(alpha: 0.12)
                        : const Color(0xFF1F1C12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? AppColors.errorRed : AppColors.primaryGold,
                    size: 20,
                  ),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.errorRed : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDestructive
                        ? AppColors.errorRed.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive ? AppColors.errorRed.withValues(alpha: 0.5) : AppColors.textMuted,
                  size: 20,
                ),
              ),
              if (index < tiles.length - 1) const Divider(color: AppColors.cardBorder, height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 18),
        label: Text(
          'Sair da Conta',
          style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.errorRed, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(color: AppColors.primaryGold, fontSize: 34, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildAvatarStack(String initial) {
    return Center(
      child: GestureDetector(
        onTap: _isUploadingPhoto ? null : _pickAndUploadProfilePhoto,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold, width: 2.5),
                color: AppColors.cardElevated,
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _user?.photo != null && _user!.photo!.isNotEmpty
                        ? Image.network(
                            _user!.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildAvatar(initial),
                          )
                        : _buildAvatar(initial),
                    if (_isUploadingPhoto)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                shape: BoxShape.circle,
              ),
              child: _isUploadingPhoto
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textDark,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.textDark,
                      size: 16,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
