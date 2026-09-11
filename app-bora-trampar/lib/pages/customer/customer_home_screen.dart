import 'package:app_bora_trampar/core/services/auth_service.dart';
import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/core/theme/app_colors.dart';
import 'package:app_bora_trampar/core/widgets/main_app_bar.dart';
import 'package:app_bora_trampar/models/category_model.dart';
import 'package:app_bora_trampar/models/order_request_model.dart';
import 'package:app_bora_trampar/models/profile_professional_model.dart';
import 'package:app_bora_trampar/models/user_model.dart';
import 'package:app_bora_trampar/pages/_old/categories/category_selection_screen.dart';
import 'package:app_bora_trampar/pages/_old/services/service_selection_screen.dart';
import 'package:app_bora_trampar/repositories/category/category_repository.dart';
import 'package:app_bora_trampar/repositories/profile/profile_professional_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _authService = AuthService();

  final _profileRepo = ProfileProfessionalRepository();
  final _categoryRepo = CategoryRepository();

  List<CategoryModel> _categories = [];
  ProfileProfessionalModel? _profile;
  UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await _authService.getCurrentUser();
      final profile = await _profileRepo.getMe();
      final categories = await _categoryRepo.getCategories();

      setState(() {
        _user = user;
        _profile = profile;
        _categories = categories;
      });
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _user?.name.split(' ').first ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(title: 'Bora Trampa'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.all(14),
            children: [
              if (_isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (!_isLoading) ...[
                _buildHeaderSection(userName),
                SizedBox(height: 14),
                _buildCustomerView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String userName) {
    // final radius = _profile?.address.serviceRadiusKm ?? 25;
    // final city = _profile?.address.city ?? '';
    // final state = _profile?.address.state ?? '';
    // final hasLocation = city.isNotEmpty && state.isNotEmpty;

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
                        if ((_profile?.identityVerificationStatus
                                .toLowerCase() ==
                            'approved')) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encontre profissionais de confiança para sua diária',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerView() {
    final filteredCategories = _categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            onChanged: (v) => setState(() => {}),
            decoration: InputDecoration(
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),

              hintText:
                  'Buscar serviço ou profissional (ex: Pintor, Diarista)...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Container(
        //   child: ElevatedButton.icon(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => const CustomerReviewsScreen(),
        //         ),
        //       );
        //     },
        //     icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        //     label: Text(
        //       'Avaliar Profissional',
        //       style: GoogleFonts.inter(
        //         color: AppColors.textDark,
        //         fontSize: 15,
        //         fontWeight: FontWeight.w700,
        //       ),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primaryGold,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(14),
        //       ),
        //       elevation: 0,
        //     ),
        //   ),
        // ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categorias de Serviços',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (_categories.length > 4)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategorySelectionScreen(),
                    ),
                  );
                },
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (filteredCategories.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Text(
                'Nenhuma categoria encontrada.',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          GridView.count(
            crossAxisCount: filteredCategories.length == 1 ? 1 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: filteredCategories.length == 1 ? 2.6 : 1.35,
            children: filteredCategories.take(4).map((cat) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceSelectionScreen(
                        orderRequest: OrderRequestModel(selectedCategory: cat),
                        category: cat,
                      ),
                    ),
                  );
                },
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
                        child: Icon(
                          cat.icon,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                      ),
                      Text(
                        cat.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E1A10),
                ),
                child: const Icon(
                  Icons.add_task_rounded,
                  color: AppColors.primaryGold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitar Novo Profissional',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Escolha data, horário e receba propostas em minutos.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategorySelectionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // if (_nearbyPros.isNotEmpty) ...[
        //   const SizedBox(height: 28),
        //   Text(
        //     'Profissionais na sua Região',
        //     style: GoogleFonts.inter(
        //       fontSize: 17,
        //       fontWeight: FontWeight.w700,
        //       color: AppColors.textPrimary,
        //     ),
        //   ),
        //   const SizedBox(height: 14),
        //   ..._nearbyPros.take(3).map((pro) {
        //     return Container(
        //       margin: const EdgeInsets.only(bottom: 12),
        //       padding: const EdgeInsets.all(16),
        //       decoration: BoxDecoration(
        //         color: AppColors.cardBackground,
        //         borderRadius: BorderRadius.circular(16),
        //         border: Border.all(color: AppColors.cardBorder),
        //       ),
        //       child: Row(
        //         children: [
        //           CircleAvatar(
        //             radius: 24,
        //             backgroundColor: AppColors.cardElevated,
        //             backgroundImage: pro.avatarUrl.isNotEmpty
        //                 ? NetworkImage(pro.avatarUrl)
        //                 : null,
        //             child: pro.avatarUrl.isEmpty
        //                 ? Text(
        //                     pro.name.isNotEmpty ? pro.name[0] : 'P',
        //                     style: GoogleFonts.inter(
        //                       color: AppColors.primaryGold,
        //                       fontWeight: FontWeight.w700,
        //                     ),
        //                   )
        //                 : null,
        //           ),
        //           const SizedBox(width: 14),
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(
        //                   pro.name,
        //                   style: GoogleFonts.inter(
        //                     fontSize: 15,
        //                     fontWeight: FontWeight.w700,
        //                     color: AppColors.textPrimary,
        //                   ),
        //                 ),
        //                 const SizedBox(height: 2),
        //                 Text(
        //                   pro.role,
        //                   style: GoogleFonts.inter(
        //                     fontSize: 12,
        //                     color: AppColors.textSecondary,
        //                   ),
        //                 ),
        //                 const SizedBox(height: 4),
        //                 Row(
        //                   children: [
        //                     const Icon(
        //                       Icons.star_rounded,
        //                       color: AppColors.primaryGold,
        //                       size: 14,
        //                     ),
        //                     const SizedBox(width: 2),
        //                     Text(
        //                       pro.rating > 0
        //                           ? pro.rating.toStringAsFixed(1)
        //                           : '--',
        //                       style: GoogleFonts.inter(
        //                         fontSize: 11,
        //                         fontWeight: FontWeight.w700,
        //                         color: AppColors.textPrimary,
        //                       ),
        //                     ),
        //                     const SizedBox(width: 8),
        //                     Text(
        //                       '${pro.completedServicesCount} diárias',
        //                       style: GoogleFonts.inter(
        //                         fontSize: 11,
        //                         color: AppColors.textMuted,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //           ElevatedButton(
        //             onPressed: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (_) => ProfessionalProfileScreen(
        //                     professional: pro,
        //                     orderRequest: OrderRequestModel(
        //                       selectedCategory: _categories.isNotEmpty
        //                           ? _categories.first
        //                           : null,
        //                     ),
        //                   ),
        //                 ),
        //               );
        //             },
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: AppColors.primaryGold,
        //               foregroundColor: AppColors.textDark,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               padding: const EdgeInsets.symmetric(
        //                 horizontal: 12,
        //                 vertical: 8,
        //               ),
        //               minimumSize: Size.zero,
        //             ),
        //             child: Text(
        //               'Ver Perfil',
        //               style: GoogleFonts.inter(
        //                 fontSize: 11,
        //                 fontWeight: FontWeight.w800,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   }),
        // ],
      ],
    );
  }
}
