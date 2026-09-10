import 'dart:async';
import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../models/category_model.dart';
import '../../models/professional_model.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/appointment/appointment_repository.dart';
import '../../repositories/category/category_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/user/user_repository.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToProfile;

  const ProfessionalHomeScreen({
    super.key,
    this.onNavigateToSchedule,
    this.onNavigateToProfile,
  });

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreen();
}

class _ProfessionalHomeScreen extends State<ProfessionalHomeScreen> {
  final _categoryRepo = CategoryRepository();
  final _profileRepo = ProfileProfessionalRepository();
  final _appointmentRepo = AppointmentRepository();
  final _userRepo = UserRepository();

  UserModel? _user;
  ProfileProfessionalModel? _profile;
  List<CategoryModel> _categories = [];
  List<AppointmentModel> _appointments = [];
  List<ProfessionalModel> _nearbyPros = [];
  bool _isLoading = true;
  bool _isStartLoading = true;
  bool _isAvailable = true;
  bool _showBalance = true;
  String _customerSearchQuery = '';
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _reloadAppointmentsSilently();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _reloadAppointmentsSilently() async {
    final role = (_user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');
    if (!isPro) return;

    final fresh = await _appointmentRepo.getAppointments();
    if (mounted && fresh.isNotEmpty) {
      setState(() {
        _appointments = fresh;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    final categories = await _categoryRepo.getCategories();
    final role = (user?.role ?? '').toLowerCase();
    final isPro = role.contains('prof') || role.contains('prestador');

    ProfileProfessionalModel? profile;
    List<AppointmentModel> appointments = [];
    List<ProfessionalModel> pros = [];

    if (isPro) {
      profile = await _profileRepo.getMe();
      appointments = await _appointmentRepo.getAppointments();
    } else {
      appointments = await _appointmentRepo.getAppointments();
      pros = await _userRepo.getProfessionals();
    }

    if (mounted) {
      setState(() {
        _user = user;
        _categories = categories;
        _profile = profile;
        _appointments = appointments;
        _nearbyPros = pros;
        _isAvailable = profile?.isAvailableNow ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    await _profileRepo.updateAvailability(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Você está ONLINE para receber chamados!'
              : 'Você entrou em PAUSA.',
          style: GoogleFonts.inter(
            color: value ? AppColors.textDark : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: value ? AppColors.primaryGold : AppColors.cardElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openMaps(String? address) async {
    if (address == null || address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço não informado no agendamento.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o mapa.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _startService(String id) async {
    try {
      setState(() {
        _isStartLoading = true;
      });
      await _appointmentRepo.startAppointment(id);
      if (mounted) Toastfy.show(context, "Serviço iniciado!", "success");
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() {
        _isStartLoading = false;
      });
    }
  }

  Future<void> _finishService(String id) async {
    try {
      setState(() {
        _isStartLoading = true;
      });
      await _appointmentRepo.finishAppointment(id);
      if (mounted) Toastfy.show(context, "Serviço finalizado!", "success");

      await _loadData();
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() {
        _isStartLoading = false;
      });
    }
  }

  void _showServicesModal() {
    final services = _profile?.services ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meus Serviços & Preços',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (services.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Nenhum serviço cadastrado ainda no seu perfil.',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...services.map((s) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.serviceName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.categoryName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R\$ ${s.price.toStringAsFixed(2).replaceAll('.', ',')} / ${s.priceType}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareModal() {
    final userId = _user?.id ?? '';
    final link = 'https://boratrampar.com.br/pro/$userId';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 56,
                  color: AppColors.primaryGold,
                ),
                const SizedBox(height: 14),
                Text(
                  'Divulgue seu Perfil Bora Trampar',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compartilhe seu link exclusivo com clientes para receber solicitações diretas com pagamento seguro.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          link,
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGoldLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: link));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Link do perfil copiado com sucesso!',
                              ),
                              backgroundColor: AppColors.primaryGold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _user?.name.split(' ').first ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Bora Trampa',
        onProfileTap: widget.onNavigateToProfile,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildHeaderSection(userName),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  ),
                )
              else
                _buildProfessionalView(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String userName) {
    final radius = _profile?.address.serviceRadiusKm ?? 25;
    final city = _profile?.address.city ?? '';
    final state = _profile?.address.state ?? '';
    final hasLocation = city.isNotEmpty && state.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const RadialGradient(
          center: Alignment(0.8, -0.6),
          radius: 1.2,
          colors: [Color(0xFF2B2514), Color(0xFF141414)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Olá, $userName 👋',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // if (!isCustomer &&
                        //     (_profile?.identityVerificationStatus
                        //             .toLowerCase() ==
                        //         'approved')) ...[
                        //   const SizedBox(width: 6),
                        //   const Icon(
                        //     Icons.verified_rounded,
                        //     color: AppColors.primaryGold,
                        //     size: 20,
                        //   ),
                        // ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   isCustomer
                    //       ? 'Encontre profissionais de confiança para sua diária'
                    //       : (_profile?.profession.isNotEmpty == true
                    //             ? _profile!.profession
                    //             : 'Profissional'),
                    //   style: GoogleFonts.inter(
                    //     fontSize: 13,
                    //     color: AppColors.textSecondary,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Profissional',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isAvailable
                          ? AppColors.success
                          : AppColors.textMuted,
                      shape: BoxShape.circle,
                      boxShadow: _isAvailable
                          ? [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAvailable
                        ? 'Disponível para novos trampos'
                        : 'Em Pausa / Ocupado',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _isAvailable
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isAvailable,
                activeThumbColor: AppColors.textDark,
                activeTrackColor: AppColors.primaryGold,
                inactiveTrackColor: AppColors.cardElevated,
                onChanged: _toggleAvailability,
              ),
            ],
          ),
          if (hasLocation) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.primaryGold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Atendendo em até $radius km • $city, $state',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfessionalView() {
    final now = DateTime.now();

    final completedAppointments = _appointments.where((a) {
      return a.status == "Finish";
    }).toList();

    final monthAppointments = completedAppointments.where((a) {
      return a.date.month == now.month && a.date.year == now.year;
    }).toList();

    final todayAppointments = completedAppointments.where((a) {
      return a.date.day == now.day &&
          a.date.month == now.month &&
          a.date.year == now.year;
    }).toList();

    final monthRevenue = monthAppointments.fold<double>(
      0.0,
      (sum, a) => sum + (a.price ?? 0.0),
    );
    final todayRevenue = todayAppointments.fold<double>(
      0.0,
      (sum, a) => sum + (a.price ?? 0.0),
    );
    final completedCount = completedAppointments.length;

    final pendingRequests = _appointments.where((a) {
      final isForMe =
          _user == null ||
          a.professionalId.isEmpty ||
          a.professionalId == 'prof_default' ||
          a.professionalId.trim().toLowerCase() ==
              _user!.id.trim().toLowerCase() ||
          (_profile != null &&
              _profile!.id != null &&
              a.professionalId.trim().toLowerCase() ==
                  _profile!.id!.trim().toLowerCase());
      if (!isForMe) return false;

      return a.status == "PendingAcceptance";
    }).toList();

    final activeAppointments = _appointments.where((a) {
      final s = a.status.toLowerCase();
      return s == 'confirmed' ||
          s == 'paid' ||
          s == 'in_progress' ||
          s == 'accepted';
    }).toList();

    activeAppointments.sort((a, b) => a.date.compareTo(b.date));
    final nextJob = activeAppointments.isNotEmpty
        ? activeAppointments.first
        : null;

    final startedAppointments = _appointments
        .where((e) => e.status == "StartService")
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFinancialSummaryCard(monthRevenue, todayRevenue, completedCount),
        const SizedBox(height: 24),
        _buildNextJobSection(nextJob),
        const SizedBox(height: 24),
        if (startedAppointments.isEmpty)
          _buildPendingRequestsSection(pendingRequests),
        const SizedBox(height: 24),
        if (startedAppointments.isNotEmpty)
          _buildStartSection(startedAppointments),
        const SizedBox(height: 24),
        _buildQuickActionsSection(),
      ],
    );
  }

  Widget _buildFinancialSummaryCard(
    double monthRevenue,
    double todayRevenue,
    int completedCount,
  ) {
    final rating = _profile?.rating ?? 0.0;
    final reviewCount = _profile?.reviewCount ?? 0;
    final ratingText = rating > 0
        ? rating.toStringAsFixed(1)
        : 'Sem avaliações';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resumo de Ganhos',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _showBalance
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _showBalance = !_showBalance),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganhos do Mês',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showBalance
                          ? 'R\$ ${monthRevenue.toStringAsFixed(2).replaceAll('.', ',')}'
                          : '••••••••',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.cardBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoje',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showBalance
                          ? 'R\$ ${todayRevenue.toStringAsFixed(2).replaceAll('.', ',')}'
                          : '••••••••',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.primaryGold,
                  title: ratingText,
                  subtitle: '$reviewCount avaliações',
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.cardBorder),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.success,
                  title: '$completedCount',
                  subtitle: 'Concluídos',
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.cardBorder),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.bolt_rounded,
                  iconColor: Colors.amber,
                  title: 'Ativo',
                  subtitle: 'Status da Conta',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildNextJobSection(AppointmentModel? nextJob) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximo Trampo',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: widget.onNavigateToSchedule,
              child: Text(
                'Ver agenda completa',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (nextJob != null) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${DateFormat('dd/MM').format(nextJob.date)}${nextJob.hour.isNotEmpty ? " • ${nextJob.hour}" : ""}',
                        style: GoogleFonts.inter(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (nextJob.price != null && nextJob.price! > 0)
                      Text(
                        'R\$ ${nextJob.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nextJob.serviceName ??
                      nextJob.categoryName ??
                      'Serviço Agendado',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (nextJob.customerName != null &&
                    nextJob.customerName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cliente: ${nextJob.customerName}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (nextJob.address != null && nextJob.address!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          nextJob.address!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (nextJob.address != null && nextJob.address!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openMaps(nextJob.address),
                          icon: const Icon(
                            Icons.directions_rounded,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                          label: Text(
                            'Rota Maps',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryGold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    if (nextJob.status == "Accepted") const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startService(nextJob.id),
                        icon: const Icon(
                          Icons.play_arrow,
                          color: AppColors.textDark,
                          size: 16,
                        ),
                        label: Text(
                          'Inciar Serviço',
                          style: GoogleFonts.inter(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.primaryGold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhum trampo agendado',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mantenha seu status Online para receber chamados de clientes.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingRequestsSection(List<AppointmentModel> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Solicitações Recebidas (${requests.length})',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (requests.isNotEmpty)
              Text(
                'Novos chamados',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Text(
                'Nenhuma solicitação pendente no momento.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...requests.take(3).map((req) {
            final dateStr = DateFormat('dd/MM/yyyy').format(req.date);
            final hourStr = req.hour.isNotEmpty ? ' • ${req.hour}' : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          req.serviceName ??
                              req.categoryName ??
                              'Serviço Solicitado',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (req.price != null && req.price! > 0)
                        Text(
                          'R\$ ${req.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${req.customerName != null ? "Cliente: ${req.customerName} • " : ""}Data: $dateStr$hourStr',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (req.address != null && req.address!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Local: ${req.address}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final success = await _appointmentRepo
                                .declineAppointment(req.id);
                            if (success && mounted) {
                              setState(() {
                                _appointments = _appointments.map((a) {
                                  if (a.id == req.id) {
                                    return AppointmentModel(
                                      id: a.id,
                                      professionalId: a.professionalId,
                                      customerId: a.customerId,
                                      date: a.date,
                                      hour: a.hour,
                                      serviceName: a.serviceName,
                                      categoryName: a.categoryName,
                                      customerName: a.customerName,
                                      professionalName: a.professionalName,
                                      address: a.address,
                                      description: a.description,
                                      notes: a.notes,
                                      photoUrls: a.photoUrls,
                                      price: a.price,
                                      status: 'Declined',
                                      serviceId: "",
                                    );
                                  }
                                  return a;
                                }).toList();
                              });
                              _loadData();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Recusar',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await _appointmentRepo
                                .acceptAppointment(req.id);
                            if (success && mounted) {
                              setState(() {
                                _appointments = _appointments.map((a) {
                                  if (a.id == req.id) {
                                    return AppointmentModel(
                                      id: a.id,
                                      professionalId: a.professionalId,
                                      customerId: a.customerId,
                                      date: a.date,
                                      hour: a.hour,
                                      serviceName: a.serviceName,
                                      categoryName: a.categoryName,
                                      customerName: a.customerName,
                                      professionalName: a.professionalName,
                                      address: a.address,
                                      description: a.description,
                                      notes: a.notes,
                                      photoUrls: a.photoUrls,
                                      price: a.price,
                                      status: 'Accepted',
                                      serviceId: "",
                                    );
                                  }
                                  return a;
                                }).toList();
                              });
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Trampo aceito com sucesso! Verifique na sua Agenda.',
                                  ),
                                  backgroundColor: AppColors.primaryGold,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'Aceitar Trampo',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStartSection(List<AppointmentModel> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Serviço em andamento',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...requests.take(3).map((req) {
          final dateStr = DateFormat('dd/MM/yyyy').format(req.date);
          final hourStr = req.hour.isNotEmpty ? ' • ${req.hour}' : '';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        req.serviceName ??
                            req.categoryName ??
                            'Serviço Solicitado',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (req.price != null && req.price! > 0)
                      Text(
                        'R\$ ${req.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${req.customerName != null ? "Cliente: ${req.customerName} • " : ""}Data: $dateStr$hourStr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (req.address != null && req.address!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Local: ${req.address}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _finishService(req.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Finalizar Trampo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atalhos do Profissional',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              icon: Icons.calendar_month_rounded,
              title: 'Minha Agenda',
              subtitle: 'Dias e horários',
              onTap: widget.onNavigateToSchedule,
            ),
            _buildActionCard(
              icon: Icons.handyman_rounded,
              title: 'Meus Serviços',
              subtitle: 'Preços e diárias',
              onTap: _showServicesModal,
            ),
            _buildActionCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Extrato & Pix',
              subtitle: 'Ver recebimentos',
              onTap: widget.onNavigateToProfile,
            ),
            _buildActionCard(
              icon: Icons.share_rounded,
              title: 'Divulgar Perfil',
              subtitle: 'Link exclusivo',
              onTap: _showShareModal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1C12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
