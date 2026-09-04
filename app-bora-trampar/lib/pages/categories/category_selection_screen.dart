import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/category_model.dart';
import '../../models/order_request_model.dart';
import '../../repositories/category/category_repository.dart';
import '../services/service_selection_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final OrderRequestModel? orderRequest;

  const CategorySelectionScreen({super.key, this.orderRequest});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();

  late OrderRequestModel _orderRequest;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _orderRequest = widget.orderRequest ?? OrderRequestModel();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _categoryRepository.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategory = _orderRequest.selectedCategory ?? _categories.first;
          _orderRequest.selectedCategory = _selectedCategory;
        }
        _isLoading = false;
      });
    }
  }

  void _onSelectCategory(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
      _orderRequest.selectedCategory = category;
    });
  }

  void _handleContinue() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecione uma categoria para prosseguir.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceSelectionScreen(
          orderRequest: _orderRequest,
          category: _selectedCategory!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sou cliente',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Central de Ajuda Bora Trampar',
                    style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            },
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryGold,
              size: 18,
            ),
            label: Text(
              'Ajuda',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AppStepper(totalSteps: 4, currentStep: 1),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGold),
                    )
                  : _categories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.grid_off_rounded, color: AppColors.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma categoria encontrada',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Não há categorias cadastradas no momento.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                          children: const [
                                            TextSpan(text: 'Selecione a '),
                                            TextSpan(
                                              text: 'Categoria',
                                              style: TextStyle(color: AppColors.primaryGold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Escolha o segmento da diária para ver os serviços especializados.',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const BoraTrampaLogo(size: 34, showSubtitle: false, isHorizontal: false),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ..._categories.map((cat) {
                              final isSelected = _selectedCategory?.id == cat.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _onSelectCategory(cat),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.cardElevated : AppColors.cardBackground,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryGold.withValues(alpha: 0.2)
                                                : const Color(0xFF1F1C12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(cat.icon, color: AppColors.primaryGold, size: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cat.title,
                                                style: GoogleFonts.inter(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                cat.subtitle,
                                                style: GoogleFonts.inter(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.primaryGold,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        ),
            ),
            if (!_isLoading && _categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(
                  text: 'Continuar para Serviços',
                  onPressed: _handleContinue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
