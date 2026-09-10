import 'package:app_bora_trampar/core/theme/app_colors.dart';
import 'package:app_bora_trampar/core/widgets/bora_trampa_logo.dart';
import 'package:app_bora_trampar/core/widgets/primary_button.dart';
import 'package:app_bora_trampar/models/category_model.dart';
import 'package:app_bora_trampar/models/order_request_model.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_2_screen.dart';
import 'package:app_bora_trampar/repositories/category/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerOrderTab1Screen extends StatefulWidget {
  final OrderRequestModel? orderRequest;
  const CustomerOrderTab1Screen({super.key, this.orderRequest});

  @override
  State<CustomerOrderTab1Screen> createState() =>
      _CustomerOrderTab1ScreenState();
}

class _CustomerOrderTab1ScreenState extends State<CustomerOrderTab1Screen> {
  final _categoryRepository = CategoryRepository();

  late OrderRequestModel _orderRequest;
  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

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
          _selectedCategory =
              _orderRequest.selectedCategory ?? _categories.first;
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
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerOrderTab2Screen(
          selectedCategory: _selectedCategory!,
          orderRequest: _orderRequest,
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
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
                    style: GoogleFonts.inter(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                  const BoraTrampaLogo(
                    size: 34,
                    showSubtitle: false,
                    isHorizontal: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (!_isLoading) _buildCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              children: [
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
                          color: isSelected
                              ? AppColors.cardElevated
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGold
                                : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGold.withValues(
                                        alpha: 0.2,
                                      )
                                    : const Color(0xFF1F1C12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat.icon,
                                color: AppColors.primaryGold,
                                size: 24,
                              ),
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
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: PrimaryButton(
              text: 'Continuar para Serviços',
              onPressed: _handleContinue,
            ),
          ),
        ],
      ),
    );
  }
}
