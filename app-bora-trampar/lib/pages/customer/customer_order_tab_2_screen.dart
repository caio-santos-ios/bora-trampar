import 'package:app_bora_trampar/core/theme/app_colors.dart';
import 'package:app_bora_trampar/core/widgets/app_stepper.dart';
import 'package:app_bora_trampar/core/widgets/bora_trampa_logo.dart';
import 'package:app_bora_trampar/core/widgets/primary_button.dart';
import 'package:app_bora_trampar/models/category_model.dart';
import 'package:app_bora_trampar/models/order_request_model.dart';
import 'package:app_bora_trampar/models/service_item_model.dart';
import 'package:app_bora_trampar/pages/customer/customer_order_tab_3_screen.dart';
import 'package:app_bora_trampar/repositories/services/services_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerOrderTab2Screen extends StatefulWidget {
  final OrderRequestModel orderRequest;
  final CategoryModel selectedCategory;
  const CustomerOrderTab2Screen({
    super.key,
    required this.selectedCategory,
    required this.orderRequest,
  });

  @override
  State<CustomerOrderTab2Screen> createState() =>
      _CustomerOrderTab2ScreenState();
}

class _CustomerOrderTab2ScreenState extends State<CustomerOrderTab2Screen> {
  final _servicesRepository = ServicesRepository();

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
    final services = await _servicesRepository.getServices(
      categoryId: widget.selectedCategory.id,
    );

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

    widget.orderRequest.selectedCategory = widget.selectedCategory;
    widget.orderRequest.selectedServices = selectedList;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerOrderTab3Screen(orderRequest: widget.orderRequest),
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
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 18),
        child: SafeArea(
          child: Column(
            children: [
              AppStepper(totalSteps: 4, currentStep: 2),
              const SizedBox(height: 12),
              if (_isLoading) ...[
                Expanded(
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
              ...[
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
                            widget.selectedCategory.title,
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
                    const BoraTrampaLogo(
                      size: 34,
                      showSubtitle: true,
                      isHorizontal: false,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 15),
              if (!_isLoading) _buildServices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServices() {
    final selectedCount = _selectedServiceIds.length;

    return Expanded(
      child: Column(
        children: [
          if (_services.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  ServiceItemModel serviceItemModel = _services[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _toggleService(serviceItemModel),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedServiceIds.contains(serviceItemModel.id)
                              ? AppColors.cardElevated
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                _selectedServiceIds.contains(
                                  serviceItemModel.id,
                                )
                                ? AppColors.primaryGold
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              serviceItemModel.effectiveIcon,
                              color: AppColors.primaryGold,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${index + 1}. ${serviceItemModel.name}',
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
                                color:
                                    _selectedServiceIds.contains(
                                      serviceItemModel.id,
                                    )
                                    ? AppColors.primaryGold
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      _selectedServiceIds.contains(
                                        serviceItemModel.id,
                                      )
                                      ? AppColors.primaryGold
                                      : AppColors.cardBorder,
                                  width: 1.5,
                                ),
                              ),
                              child:
                                  _selectedServiceIds.contains(
                                    serviceItemModel.id,
                                  )
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
                  );
                },
              ),
            ),
          ],

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
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Continuar',
            onPressed: _selectedServiceIds.isNotEmpty ? _onContinue : null,
          ),
        ],
      ),
    );
  }
}
