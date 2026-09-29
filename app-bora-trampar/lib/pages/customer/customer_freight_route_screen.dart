import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/util_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/location_helper.dart';
import '../../core/widgets/primary_button.dart';
import '../../repositories/address/address_repository.dart';
import 'customer_freight_details_screen.dart';

class FreightRouteResult {
  final AddressSuggestion origin;
  final AddressSuggestion destination;
  final RouteDistance route;

  FreightRouteResult({
    required this.origin,
    required this.destination,
    required this.route,
  });
}

class CustomerFreightRouteScreen extends StatefulWidget {
  const CustomerFreightRouteScreen({super.key});

  @override
  State<CustomerFreightRouteScreen> createState() => _CustomerFreightRouteScreenState();
}

class _CustomerFreightRouteScreenState extends State<CustomerFreightRouteScreen> {
  final _addressRepo = AddressRepository();

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _originFocus = FocusNode();
  final _destinationFocus = FocusNode();

  AddressSuggestion? _origin;
  AddressSuggestion? _destination;

  List<AddressSuggestion> _suggestions = [];
  bool _editingOrigin = true;
  bool _isSearching = false;
  Timer? _debounce;

  RouteDistance? _route;
  bool _isCalculating = false;
  bool _isLocating = false;
  String? _routeError;

  @override
  void dispose() {
    _debounce?.cancel();
    _originController.dispose();
    _destinationController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  void _onChanged(String value, {required bool isOrigin}) {
    setState(() {
      _editingOrigin = isOrigin;
      if (isOrigin) {
        _origin = null;
      } else {
        _destination = null;
      }
      _route = null;
      _routeError = null;
    });

    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _addressRepo.searchAddresses(value);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      } on DioException catch (err) {
        if (!mounted) return;
        setState(() => _isSearching = false);
        UtilService.normalizeError(context, err);
      }
    });
  }

  void _selectSuggestion(AddressSuggestion s) {
    if (s.latitude == null || s.longitude == null) {
      _showSnack('Este endereço não tem coordenadas. Escolha outro resultado.', isError: true);
      return;
    }

    setState(() {
      if (_editingOrigin) {
        _origin = s;
        _originController.text = s.description;
      } else {
        _destination = s;
        _destinationController.text = s.description;
      }
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();

    if (_editingOrigin && _destination == null) {
      _editingOrigin = false;
      Future.microtask(() => _destinationFocus.requestFocus());
    }

    _calculateRoute();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final location = await LocationHelper.getCurrentLocation();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (location == null) {
      _showSnack('Não foi possível obter sua localização. Verifique a permissão do GPS.', isError: true);
      return;
    }

    setState(() {
      _origin = AddressSuggestion(
        title: location.address,
        description: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        city: location.city,
        state: location.state,
      );
      _originController.text = location.address;
      _suggestions = [];
    });
    _calculateRoute();
  }

  void _swap() {
    setState(() {
      final tmpAddress = _origin;
      _origin = _destination;
      _destination = tmpAddress;

      final tmpText = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = tmpText;

      _suggestions = [];
      _route = null;
      _routeError = null;
    });
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null) return;

    setState(() {
      _isCalculating = true;
      _routeError = null;
      _route = null;
    });

    try {
      final route = await _addressRepo.getDistance(
        originLat: origin.latitude!,
        originLon: origin.longitude!,
        destinationLat: destination.latitude!,
        destinationLon: destination.longitude!,
      );

      if (!mounted) return;
      setState(() {
        _route = route;
        _routeError = route == null ? 'Não encontramos uma rota entre os dois endereços.' : null;
        _isCalculating = false;
      });
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() {
        _routeError = 'Não foi possível calcular a distância. Tente novamente.';
        _isCalculating = false;
      });
      UtilService.normalizeError(context, err);
    }
  }

  void _onContinue() {
    if (_origin == null || _destination == null) {
      _showSnack('Informe o endereço de retirada e o de entrega.', isError: true);
      return;
    }
    if (_route == null) {
      _showSnack('Aguarde o cálculo da distância.', isError: true);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerFreightDetailsScreen(
          routeResult: FreightRouteResult(
            origin: _origin!,
            destination: _destination!,
            route: _route!,
          ),
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: isError ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryGold,
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Retirada e Entrega',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildAddressCard(),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                        ),
                      ),
                    ),
                  if (_suggestions.isNotEmpty) _buildSuggestions(),
                  if (_suggestions.isEmpty && !_isSearching) _buildRouteSummary(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
              ),
              child: PrimaryButton(
                text: 'Continuar',
                isLoading: _isCalculating,
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marcadores e linha ligando origem -> destino
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                const Icon(Icons.trip_origin_rounded, color: AppColors.success, size: 18),
                Container(width: 2, height: 42, color: AppColors.cardBorder),
                const Icon(Icons.location_on_rounded, color: AppColors.errorRed, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildField(
                  controller: _originController,
                  focusNode: _originFocus,
                  hint: 'Endereço de retirada',
                  isOrigin: true,
                  selected: _origin != null,
                ),
                const SizedBox(height: 10),
                _buildField(
                  controller: _destinationController,
                  focusNode: _destinationFocus,
                  hint: 'Endereço de entrega',
                  isOrigin: false,
                  selected: _destination != null,
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Inverter origem e destino',
                icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryGold),
                onPressed: _swap,
              ),
              IconButton(
                tooltip: 'Usar minha localização como retirada',
                icon: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                      )
                    : const Icon(Icons.my_location_rounded, color: AppColors.primaryGold),
                onPressed: _isLocating ? null : _useCurrentLocation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool isOrigin,
    required bool selected,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTap: () => setState(() {
        _editingOrigin = isOrigin;
        _suggestions = [];
      }),
      onChanged: (v) => _onChanged(v, isOrigin: isOrigin),
      textInputAction: isOrigin ? TextInputAction.next : TextInputAction.done,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: selected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18)
            : (controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      controller.clear();
                      _onChanged('', isOrigin: isOrigin);
                    },
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: selected ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: selected ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _suggestions.length; i++) ...[
            ListTile(
              dense: true,
              leading: const Icon(Icons.place_outlined, color: AppColors.primaryGold, size: 20),
              title: Text(
                _suggestions[i].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _suggestions[i].description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
              ),
              onTap: () => _selectSuggestion(_suggestions[i]),
            ),
            if (i < _suggestions.length - 1) const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    if (_isCalculating) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
      );
    }

    if (_routeError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _routeError!,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: _calculateRoute,
                child: Text('Tentar de novo', style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    final route = _route;
    if (route == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            const Icon(Icons.route_rounded, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Digite os endereços de retirada e entrega\npara calcular a distância',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(child: _buildMetric(Icons.straighten_rounded, 'Distância', route.distanceLabel)),
            Container(width: 1, height: 40, color: AppColors.divider),
            Expanded(child: _buildMetric(Icons.schedule_rounded, 'Tempo estimado', route.durationLabel)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}