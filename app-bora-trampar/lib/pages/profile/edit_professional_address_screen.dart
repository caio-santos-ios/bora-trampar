import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/location_helper.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';

class EditProfessionalAddressScreen extends StatefulWidget {
  final ProfileProfessionalModel proProfile;

  const EditProfessionalAddressScreen({super.key, required this.proProfile});

  @override
  State<EditProfessionalAddressScreen> createState() =>
      _EditProfessionalAddressScreenState();
}

class _EditProfessionalAddressScreenState
    extends State<EditProfessionalAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cepController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;

  double _serviceRadiusKm = 25.0;
  double? _latitude;
  double? _longitude;
  bool _isSearchingCep = false;
  bool _isGettingLocation = false;
  bool _isSaving = false;

  final List<int> _quickRadiusOptions = [10, 20, 25, 35, 50, 75, 100];

  @override
  void initState() {
    super.initState();
    final addr = widget.proProfile.address;

    _cepController = TextEditingController(text: addr.zipCode);
    _streetController = TextEditingController(text: addr.street);
    _numberController = TextEditingController(text: addr.number);
    _complementController = TextEditingController(text: addr.complement);
    _neighborhoodController = TextEditingController(text: addr.neighborhood);
    _cityController = TextEditingController(text: addr.city);
    _stateController = TextEditingController(text: addr.state);

    if (addr.serviceRadiusKm > 0) {
      _serviceRadiusKm = addr.serviceRadiusKm.toDouble().clamp(5.0, 100.0);
    } else {
      _serviceRadiusKm = 25.0;
    }

    _latitude = addr.latitude;
    _longitude = addr.longitude;

    if (_latitude == null || _latitude == 0) {
      if (addr.location.coordinates.length >= 2) {
        _longitude = addr.location.coordinates[0];
        _latitude = addr.location.coordinates[1];
      }
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _fetchCep(String rawCep) async {
    final cleanCep = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return;

    setState(() => _isSearchingCep = true);

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      final response = await dio.get(
        'https://brasilapi.com.br/api/cep/v2/$cleanCep',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['type'] != 'service_error') {
          setState(() {
            _streetController.text = data['street']?.toString() ?? '';
            _neighborhoodController.text =
                data['neighborhood']?.toString() ?? '';
            _cityController.text = data['city']?.toString() ?? '';
            _stateController.text = data['state']?.toString() ?? '';

            final loc = data['location'];
            if (loc is Map && loc['coordinates'] is Map) {
              final rawLat = double.tryParse(
                loc['coordinates']['latitude']?.toString() ?? '0',
              );
              final rawLng = double.tryParse(
                loc['coordinates']['longitude']?.toString() ?? '0',
              );
              if (rawLat != null &&
                  rawLng != null &&
                  rawLat != 0 &&
                  rawLng != 0) {
                setState(() {
                  _latitude = rawLat;
                  _longitude = rawLng;
                });
              }
              print(_longitude);
            }
          });
          return;
        }
      }
    } catch (_) {
      try {
        final res = await LocationHelper.geocodeAddress(cleanCep);
        if (res != null) {
          setState(() {
            if (_cityController.text.isEmpty) _cityController.text = res.city;
            if (_stateController.text.isEmpty)
              _stateController.text = res.state;
            _latitude = res.latitude;
            _longitude = res.longitude;
          });
        }
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _isSearchingCep = false);
    }
  }

  Future<void> _useCurrentGpsLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final res = await LocationHelper.getCurrentLocation();
      if (res != null) {
        setState(() {
          _latitude = res.latitude;
          _longitude = res.longitude;
          if (res.city.isNotEmpty) _cityController.text = res.city;
          if (res.state.isNotEmpty) _stateController.text = res.state;
          if (_streetController.text.isEmpty && res.address.isNotEmpty) {
            _streetController.text = res.address;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Localização atual obtida com sucesso!',
                style: GoogleFonts.inter(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppColors.primaryGold,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível obter o GPS. Verifique a permissão.',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao obter localização: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final zipCode = _cepController.text.trim();
      final street = _streetController.text.trim();
      final number = _numberController.text.trim();
      final complement = _complementController.text.trim();
      final neighborhood = _neighborhoodController.text.trim();
      final city = _cityController.text.trim();
      final state = _stateController.text.trim();
      final radius = _serviceRadiusKm.round();

      double currentLat = _latitude ?? 0.0;
      double currentLng = _longitude ?? 0.0;

      if (currentLat == 0.0 || currentLng == 0.0) {
        final query = '$street, $number, $neighborhood, $city - $state, Brasil';
        final geo = await LocationHelper.geocodeAddress(
          zipCode.isNotEmpty ? zipCode : query,
        );
        if (geo != null && geo.latitude != 0.0 && geo.longitude != 0.0) {
          currentLat = geo.latitude;
          currentLng = geo.longitude;
        }
      }

      final locationModel = ProfessionalAddressLocationModel(
        type: 'Point',
        coordinates: [currentLng, currentLat],
      );

      final updatedAddress = ProfessionalAddressModel(
        zipCode: zipCode,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
        serviceRadiusKm: radius,
        location: locationModel,
      );

      final updatedProfile = widget.proProfile.copyWith(
        address: updatedAddress,
        isProfileCompleted: true,
      );

      await ProfileProfessionalRepository().saveProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Endereço e raio de atuação salvos com sucesso!',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar alterações: $e',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Endereço e Raio de Atuação',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
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
                          'Área de Atendimento',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure o endereço base de saída e o raio máximo que você aceita atender. Isso determina quais clientes encontrarão você na busca de agendamentos.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
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
                            Icons.explore_outlined,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Raio de Atendimento',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${_serviceRadiusKm.round()} km',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Você receberá solicitações de clientes em até ${_serviceRadiusKm.round()} km de distância.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryGold,
                      inactiveTrackColor: AppColors.cardBorder,
                      thumbColor: AppColors.primaryGold,
                      overlayColor: AppColors.primaryGold.withValues(
                        alpha: 0.2,
                      ),
                      valueIndicatorColor: AppColors.primaryGold,
                      valueIndicatorTextStyle: GoogleFonts.inter(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Slider(
                      value: _serviceRadiusKm,
                      min: 5.0,
                      max: 100.0,
                      divisions: 19,
                      label: '${_serviceRadiusKm.round()} km',
                      onChanged: (val) {
                        setState(() => _serviceRadiusKm = val);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5 km',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '50 km',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '100 km',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seleção Rápida:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickRadiusOptions.map((km) {
                      final isSelected = _serviceRadiusKm.round() == km;
                      return ChoiceChip(
                        label: Text('$km km'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _serviceRadiusKm = km.toDouble());
                          }
                        },
                        selectedColor: AppColors.primaryGold,
                        backgroundColor: AppColors.cardElevated,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.cardBorder,
                        ),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textDark
                              : AppColors.textPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
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
                            Icons.location_on_outlined,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Endereço Base',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _isGettingLocation
                            ? null
                            : _useCurrentGpsLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGold,
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                size: 16,
                                color: AppColors.primaryGold,
                              ),
                        label: Text(
                          'Usar GPS',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('CEP'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cepController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CepInputFormatter(),
                    ],
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '00000-000',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.cardElevated,
                      prefixIcon: const Icon(
                        Icons.pin_drop_outlined,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                      suffixIcon: _isSearchingCep
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryGold,
                              ),
                              onPressed: () => _fetchCep(_cepController.text),
                            ),
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _focusedBorder(),
                    ),
                    onChanged: (val) {
                      final clean = val.replaceAll(RegExp(r'\D'), '');
                      if (clean.length == 8) {
                        _fetchCep(clean);
                      }
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Informe o CEP';
                      }
                      if (val.replaceAll(RegExp(r'\D'), '').length != 8) {
                        return 'CEP inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Logradouro / Rua'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _streetController,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ex: Av. Paulista',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.cardElevated,
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _focusedBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Informe o logradouro'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Número'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _numberController,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '123',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.cardElevated,
                                border: _inputBorder(),
                                enabledBorder: _inputBorder(),
                                focusedBorder: _focusedBorder(),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                  ? 'Informe o número'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Complemento (opcional)'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _complementController,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Apto, Bloco, etc.',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.cardElevated,
                                border: _inputBorder(),
                                enabledBorder: _inputBorder(),
                                focusedBorder: _focusedBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildLabel('Bairro'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _neighborhoodController,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ex: Centro',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.cardElevated,
                      border: _inputBorder(),
                      enabledBorder: _inputBorder(),
                      focusedBorder: _focusedBorder(),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Informe o bairro'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Cidade'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cityController,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ex: São Paulo',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.cardElevated,
                                border: _inputBorder(),
                                enabledBorder: _inputBorder(),
                                focusedBorder: _focusedBorder(),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                  ? 'Informe a cidade'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('UF'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _stateController,
                              maxLength: 2,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'SP',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.cardElevated,
                                border: _inputBorder(),
                                enabledBorder: _inputBorder(),
                                focusedBorder: _focusedBorder(),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                  ? 'UF'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: PrimaryButton(
            text: 'Salvar Endereço e Raio',
            icon: Icons.check_circle_outline_rounded,
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryGold),
    );
  }
}
