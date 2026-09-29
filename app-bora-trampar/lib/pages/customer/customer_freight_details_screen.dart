import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/freight_order_model.dart';
import 'customer_freight_professionals_screen.dart';
import 'customer_freight_route_screen.dart';

class CustomerFreightDetailsScreen extends StatefulWidget {
  final FreightRouteResult routeResult;

  const CustomerFreightDetailsScreen({super.key, required this.routeResult});

  @override
  State<CustomerFreightDetailsScreen> createState() =>
      _CustomerFreightDetailsScreenState();
}

class _CustomerFreightDetailsScreenState
    extends State<CustomerFreightDetailsScreen> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCargoType;
  String? _selectedVehicleType;

  static const _cargoTypes = [
    'Caixas / Volumes',
    'Móveis',
    'Eletrodomésticos',
    'Materiais de Construção',
    'Equipamentos',
    'Alimentos',
    'Outros',
  ];

  static const _vehicleTypes = [
    'Moto',
    'Carro',
    'Van',
    'Caminhão Pequeno',
    'Caminhão Grande',
  ];

  double get _cargoWeight =>
      double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;

  double get _estimatedPrice => FreightOrderModel.calculatePrice(
        distanceKm: widget.routeResult.route.distanceKm,
        cargoWeightKg: _cargoWeight,
      );

  bool get _canContinue =>
      _selectedDate != null &&
      _selectedTime != null &&
      _selectedCargoType != null &&
      _cargoWeight > 0;

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGold,
            onPrimary: AppColors.textDark,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGold,
            onPrimary: AppColors.textDark,
            surface: AppColors.cardBackground,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onContinue() {
    if (!_canContinue) return;

    final scheduledDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final origin = FreightAddress.fromSuggestion(widget.routeResult.origin);
    final destination =
        FreightAddress.fromSuggestion(widget.routeResult.destination);

    final order = FreightOrderModel(
      id: '',
      originAddress: origin,
      destinationAddress: destination,
      cargoType: _selectedCargoType!,
      cargoWeight: _cargoWeight,
      distanceKm: widget.routeResult.route.distanceKm,
      durationLabel: widget.routeResult.route.durationLabel,
      scheduledDate: scheduledDate,
      vehicleType: _selectedVehicleType ?? '',
      description: _notesController.text.trim(),
      price: _estimatedPrice,
      status: 'Pending',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerFreightProfessionalsScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detalhes do Frete',
          style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildRouteSummary(),
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.calendar_today_rounded,
                    title: 'Data e Hora',
                    child: _buildDateTimePicker(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.inventory_2_rounded,
                    title: 'Tipo de Carga',
                    child: _buildCargoTypeSelector(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.scale_rounded,
                    title: 'Peso Estimado da Carga',
                    child: _buildWeightField(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.local_shipping_rounded,
                    title: 'Tipo de Veículo (opcional)',
                    child: _buildVehicleTypeSelector(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.notes_rounded,
                    title: 'Observações (opcional)',
                    child: _buildNotesField(),
                  ),
                  const SizedBox(height: 20),
                  _buildPriceSummary(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border:
                    Border(top: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: PrimaryButton(
                text: 'Buscar Profissionais',
                isLoading: false,
                onPressed: _canContinue ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSummary() {
    final route = widget.routeResult.route;
    final origin = widget.routeResult.origin;
    final destination = widget.routeResult.destination;

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
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded,
                  color: AppColors.success, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  origin.description,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(width: 2, height: 12, color: AppColors.cardBorder),
          ),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.errorRed, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination.description,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRoutePill(Icons.straighten_rounded, route.distanceLabel),
              const SizedBox(width: 8),
              _buildRoutePill(Icons.schedule_rounded, route.durationLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildDateTimePicker() {
    final dateStr = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : 'Selecionar data';
    final timeStr = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Selecionar hora';

    return Row(
      children: [
        Expanded(
          child: _buildPickerTile(
            icon: Icons.calendar_month_rounded,
            label: dateStr,
            hasValue: _selectedDate != null,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPickerTile(
            icon: Icons.access_time_rounded,
            label: timeStr,
            hasValue: _selectedTime != null,
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppColors.primaryGold.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasValue ? AppColors.primaryGold : AppColors.textMuted,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _cargoTypes.map((type) {
        final selected = _selectedCargoType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedCargoType = type),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryGold.withValues(alpha: 0.15)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.primaryGold
                    : AppColors.cardBorder,
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              type,
              style: GoogleFonts.inter(
                color:
                    selected ? AppColors.primaryGold : AppColors.textSecondary,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVehicleTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _vehicleTypes.map((type) {
        final selected = _selectedVehicleType == type;
        return GestureDetector(
          onTap: () => setState(
              () => _selectedVehicleType = selected ? null : type),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryGold.withValues(alpha: 0.15)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.primaryGold
                    : AppColors.cardBorder,
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              type,
              style: GoogleFonts.inter(
                color:
                    selected ? AppColors.primaryGold : AppColors.textSecondary,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightField() {
    return TextField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      onChanged: (_) => setState(() {}),
      style:
          GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Ex: 80',
        hintStyle:
            GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        suffixText: 'kg',
        suffixStyle: GoogleFonts.inter(
            color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: AppColors.cardBackground,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      style:
          GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Informações adicionais sobre a carga ou acesso...',
        hintStyle:
            GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final distanceKm = widget.routeResult.route.distanceKm;
    final weight = _cargoWeight;
    const baseRate = 10.0;
    const ratePerKm = 2.5;
    const ratePerKg = 0.5;

    final distanceCost = distanceKm * ratePerKm;
    final weightCost = weight * ratePerKg;
    final total = baseRate + distanceCost + weightCost;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded,
                  color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Estimativa de Preço',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow(
            'Taxa base',
            UtilBrasilFields.obterReal(baseRate),
          ),
          const SizedBox(height: 6),
          _buildPriceRow(
            '${distanceKm.toStringAsFixed(1)} km × R\$ ${ratePerKm.toStringAsFixed(2)}/km',
            UtilBrasilFields.obterReal(distanceCost),
          ),
          const SizedBox(height: 6),
          _buildPriceRow(
            '${weight.toStringAsFixed(0)} kg × R\$ ${ratePerKg.toStringAsFixed(2)}/kg',
            UtilBrasilFields.obterReal(weightCost),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total estimado',
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                UtilBrasilFields.obterReal(total),
                style: GoogleFonts.inter(
                    color: AppColors.primaryGold,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
