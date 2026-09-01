import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/service_item_model.dart';
import '../order_details/order_details_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;
  final CategoryModel category;

  const ServiceSelectionScreen({
    super.key,
    required this.orderRequest,
    required this.category,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final Set<String> _selectedServiceIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.orderRequest.selectedServices.isNotEmpty) {
      for (final s in widget.orderRequest.selectedServices) {
        _selectedServiceIds.add(s.id);
      }
    } else if (widget.category.services.isNotEmpty) {
      // Default select the first service (e.g. Pedreiro) as shown in mockup
      _selectedServiceIds.add(widget.category.services.first.id);
    }
  }

  void _toggleService(ServiceItemModel service) {
    setState(() {
      if (_selectedServiceIds.contains(service.id)) {
        if (_selectedServiceIds.length > 1) {
          _selectedServiceIds.remove(service.id);
        }
      } else {
        _selectedServiceIds.add(service.id);
      }
    });
  }

  void _onContinue() {
    final selectedList = widget.category.services
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();

    widget.orderRequest.selectedCategory = widget.category;
    widget.orderRequest.selectedServices = selectedList;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderRequest: widget.orderRequest),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('pedreiro')) return Icons.foundation_rounded;
    if (lower.contains('pintura') || lower.contains('pintor')) return Icons.format_paint_rounded;
    if (lower.contains('reparo')) return Icons.build_rounded;
    if (lower.contains('serralheiro')) return Icons.fence_rounded;
    if (lower.contains('marceneiro')) return Icons.carpenter_rounded;
    if (lower.contains('vidraceiro')) return Icons.window_rounded;
    if (lower.contains('manuten')) return Icons.settings_rounded;
    if (lower.contains('eletric')) return Icons.bolt_rounded;
    if (lower.contains('encanador')) return Icons.plumbing_rounded;
    if (lower.contains('ar-condicionado')) return Icons.ac_unit_rounded;
    if (lower.contains('limpeza')) return Icons.cleaning_services_rounded;
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedServiceIds.length;

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
            onPressed: () {},
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

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Back to categories link
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                      Text(
                        'Voltar às categorias',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Title + Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.title,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecione um ou mais serviços\nque você precisa.',
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

                // Services checklist
                ...List.generate(widget.category.services.length, (index) {
                  final service = widget.category.services[index];
                  final isChecked = _selectedServiceIds.contains(service.id);
                  final itemNumber = index + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _toggleService(service),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isChecked ? AppColors.primaryGold : AppColors.cardBorder,
                            width: isChecked ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getServiceIcon(service.name),
                              color: AppColors.primaryGold,
                              size: 26,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '$itemNumber. ${service.name}',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.primaryGold : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isChecked ? AppColors.primaryGold : AppColors.cardBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: AppColors.textDark,
                                    )
                                  : null,
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

          // Bottom Summary & CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected summary box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.2),
                          color: const Color(0xFF1E1A10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.assignment_outlined,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serviços selecionados',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$selectedCount ${selectedCount == 1 ? "serviço" : "serviços"}',
                              style: GoogleFonts.inter(
                                color: AppColors.primaryGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryGold,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  text: 'Continuar',
                  onPressed: _onContinue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
