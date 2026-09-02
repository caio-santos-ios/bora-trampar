import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/service_item_model.dart';
import '../../data/repositories/services/services_repository.dart';
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
  final ServicesRepository _servicesRepository = ServicesRepository();

  List<ServiceItemModel> _services = [];
  final Set<String> _selectedServiceIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    final services = await _servicesRepository.getServices(categoryId: widget.category.id);

    if (mounted) {
      setState(() {
        _services = services;
        if (_services.isNotEmpty) {
          _selectedServiceIds.add(_services.first.id);
        }
        _isLoading = false;
      });
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
    final selectedList = _services
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
    if (lower.contains('pedreiro') || lower.contains('alvenaria')) return Icons.foundation_rounded;
    if (lower.contains('pintura') || lower.contains('pintor')) return Icons.format_paint_rounded;
    if (lower.contains('reparo') || lower.contains('pequenos')) return Icons.build_rounded;
    if (lower.contains('serralheiro')) return Icons.fence_rounded;
    if (lower.contains('marceneiro')) return Icons.carpenter_rounded;
    if (lower.contains('vidraceiro')) return Icons.window_rounded;
    if (lower.contains('manuten')) return Icons.settings_rounded;
    if (lower.contains('eletric')) return Icons.bolt_rounded;
    if (lower.contains('encanador') || lower.contains('hidraul')) return Icons.plumbing_rounded;
    if (lower.contains('ar-condicionado')) return Icons.ac_unit_rounded;
    if (lower.contains('limpeza') || lower.contains('faxina')) return Icons.cleaning_services_rounded;
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
              child: AppStepper(totalSteps: 4, currentStep: 2),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGold),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.primaryGold,
                                size: 18,
                              ),
                              Text(
                                'Voltar às categorias',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
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
                            const BoraTrampaLogo(size: 34, showSubtitle: true, isHorizontal: false),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_services.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Center(
                              child: Text(
                                'Nenhum serviço cadastrado para esta categoria.',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < _services.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _toggleService(_services[i]),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _selectedServiceIds.contains(_services[i].id)
                                        ? AppColors.cardElevated
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _selectedServiceIds.contains(_services[i].id)
                                          ? AppColors.primaryGold
                                          : AppColors.cardBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getServiceIcon(_services[i].name),
                                        color: AppColors.primaryGold,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          '${i + 1}. ${_services[i].name}',
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
                                          color: _selectedServiceIds.contains(_services[i].id)
                                              ? AppColors.primaryGold
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _selectedServiceIds.contains(_services[i].id)
                                                ? AppColors.primaryGold
                                                : AppColors.cardBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: _selectedServiceIds.contains(_services[i].id)
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: AppColors.textDark,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 12),
                        if (_selectedServiceIds.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1C12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_outlined,
                                    color: AppColors.primaryGold,
                                    size: 20,
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
                                        '$selectedCount serviço${selectedCount > 1 ? 's' : ''}',
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
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: 'Continuar',
                onPressed: _selectedServiceIds.isNotEmpty ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
