import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_request_model.dart';
import '../services/service_selection_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final OrderRequestModel? orderRequest;

  const CategorySelectionScreen({super.key, this.orderRequest});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late OrderRequestModel _orderRequest;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _orderRequest = widget.orderRequest ?? OrderRequestModel();
    _selectedCategory = _orderRequest.selectedCategory ??
        MockData.categories.firstWhere((c) => c.id == 'construcao_reforma');
  }

  void _onSelectCategory(CategoryModel category) {
    setState(() {
      _selectedCategory = category;
      _orderRequest.selectedCategory = category;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceSelectionScreen(
          orderRequest: _orderRequest,
          category: category,
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
                const SnackBar(
                  content: Text('Central de Ajuda BoraTrampa'),
                  backgroundColor: AppColors.cardElevated,
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
      body: Column(
        children: [
          // Stepper bar
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AppStepper(totalSteps: 4, currentStep: 3),
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Row: Title + BoraTrampa Logo
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
                                TextSpan(text: 'Qual serviço\nvocê '),
                                TextSpan(
                                  text: 'precisa?',
                                  style: TextStyle(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecione uma ou mais categorias.\nVocê poderá escolher vários serviços.',
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

                // Category selection hint row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold, width: 1.5),
                        color: const Color(0xFF1E1A10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: AppColors.primaryGold,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecione uma categoria',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Depois, escolha os serviços que você precisa.',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Categories Cards
                ...MockData.categories.map((category) {
                  final isSelected = _selectedCategory?.id == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryCard(category, isSelected),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom Bar CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: PrimaryButton(
              text: 'Continuar',
              onPressed: () {
                final cat = _selectedCategory ?? MockData.categories[1];
                _onSelectCategory(cat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, bool isSelected) {
    if (category.isSpecial) {
      return InkWell(
        onTap: () => _onSelectCategory(category),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold,
                    width: 1.5,
                  ),
                  color: const Color(0xFF1E1A10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
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
      );
    }

    return InkWell(
      onTap: () => _onSelectCategory(category),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1F1C12),
              ),
              child: Icon(
                category.icon,
                color: AppColors.primaryGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
