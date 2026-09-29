import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/vehicle.dart';
import '../../repositories/upload/upload_repository.dart';
import '../../repositories/vehicle/vehicle_repository.dart';

/// Tela de cadastro/edição do veículo do transportador (seção 7 do escopo
/// de Fretes, Entregas e Transportes: Dados do Veículo).
class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  static const List<String> _vehicleTypes = [
    'Moto',
    'Carro',
    'Fiorino',
    'Saveiro',
    'Strada',
    'Utilitário',
    'Van',
    'Caminhão 3/4',
    'Caminhão toco',
    'Caminhão truck',
    'Outro',
  ];

  final _formKey = GlobalKey<FormState>();
  final _vehicleRepo = VehicleRepository();
  final _uploadRepo = UploadRepository();
  final _picker = ImagePicker();

  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _capacityController;
  late final TextEditingController _dimensionsController;

  String _vehicleType = _vehicleTypes.first;
  bool _isDefault = false;
  bool _isSaving = false;

  String _photoUrl = '';
  String _documentUrl = '';
  XFile? _newPhoto;
  XFile? _newDocument;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;

    _vehicleType = vehicle != null && _vehicleTypes.contains(vehicle.vehicleType)
        ? vehicle.vehicleType
        : _vehicleTypes.first;
    _brandController = TextEditingController(text: vehicle?.brand ?? '');
    _modelController = TextEditingController(text: vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: vehicle != null && vehicle.year > 0 ? vehicle.year.toString() : '',
    );
    _plateController = TextEditingController(text: vehicle?.plateNumber ?? '');
    _capacityController = TextEditingController(
      text: vehicle != null && vehicle.approximateCapacityKg > 0
          ? vehicle.approximateCapacityKg.toStringAsFixed(0)
          : '',
    );
    _dimensionsController = TextEditingController(text: vehicle?.dimensions ?? '');
    _isDefault = vehicle?.isDefault ?? false;
    _photoUrl = vehicle?.photoUrl ?? '';
    _documentUrl = vehicle?.documentUrl ?? '';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isDocument}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escolha a origem da foto',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGold),
                  title: const Text('Tirar Foto com a Câmera', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGold),
                  title: const Text('Escolher da Galeria', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null && mounted) {
        setState(() {
          if (isDocument) {
            _newDocument = picked;
          } else {
            _newPhoto = picked;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Não foi possível acessar a câmera ou galeria.', isError: true);
      }
    }
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String photoUrl = _photoUrl;
      String documentUrl = _documentUrl;

      if (_newPhoto != null) {
        final uploaded = await _uploadRepo.uploadImage(File(_newPhoto!.path), folder: 'vehicles');
        if (uploaded != null && uploaded.isNotEmpty) photoUrl = uploaded;
      }

      if (_newDocument != null) {
        final uploaded = await _uploadRepo.uploadImage(File(_newDocument!.path), folder: 'vehicles');
        if (uploaded != null && uploaded.isNotEmpty) documentUrl = uploaded;
      }

      final data = {
        if (_isEditing) 'id': widget.vehicle!.id,
        'vehicleType': _vehicleType,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()) ?? 0,
        'plateNumber': _plateController.text.trim().toUpperCase(),
        'approximateCapacityKg': double.tryParse(_capacityController.text.trim()) ?? 0.0,
        'dimensions': _dimensionsController.text.trim(),
        'photoUrl': photoUrl,
        'documentUrl': documentUrl,
        'isDefault': _isDefault,
      };

      final result = _isEditing
          ? await _vehicleRepo.update(data)
          : await _vehicleRepo.create(data);

      if (result != null && mounted) {
        _showSnack(
          _isEditing
              ? 'Veículo atualizado com sucesso!'
              : 'Veículo cadastrado e enviado para aprovação!',
        );
        Navigator.of(context).pop(true);
        return;
      }

      if (mounted) _showSnack('Não foi possível salvar o veículo. Tente novamente.', isError: true);
    } catch (_) {
      if (mounted) _showSnack('Erro ao salvar veículo.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          _isEditing ? 'Editar Veículo' : 'Novo Veículo',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              if (_isEditing) _buildApprovalStatusBadge(),
              DropdownButtonFormField<String>(
                initialValue: _vehicleType,
                dropdownColor: AppColors.cardBackground,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: _decoration('Tipo de veículo'),
                items: _vehicleTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _vehicleType = val ?? _vehicleType),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _brandController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Marca'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _modelController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Modelo'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Ano'),
                      validator: (v) {
                        final year = int.tryParse(v?.trim() ?? '');
                        if (year == null || year < 1950) return 'Ano inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Placa'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Capacidade aprox. (kg)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dimensionsController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: _decoration('Dimensões'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPhotoItem(
                title: 'Foto do Veículo',
                subtitle: 'Foto nítida do veículo completo',
                url: _photoUrl,
                localFile: _newPhoto,
                isDocument: false,
              ),
              const SizedBox(height: 14),
              _buildPhotoItem(
                title: 'Documentação (CRLV)',
                subtitle: 'Documento do veículo legível',
                url: _documentUrl,
                localFile: _newDocument,
                isDocument: true,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primaryGold,
                  title: Text(
                    'Usar como veículo padrão',
                    style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Será sugerido automaticamente nas solicitações de frete',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: _isEditing ? 'Salvar Alterações' : 'Cadastrar Veículo',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalStatusBadge() {
    final vehicle = widget.vehicle!;
    final status = vehicle.approvalStatus.toLowerCase();
    final isApproved = status == 'approved' || status == 'approve';
    final isRejected = status == 'rejected' || status == 'reject';

    final color = isApproved ? AppColors.success : (isRejected ? AppColors.errorRed : AppColors.warning);
    final icon = isApproved
        ? Icons.check_circle_outline_rounded
        : (isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.approvalStatusLabel,
                    style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  if (isRejected && vehicle.approvalNotes.isNotEmpty)
                    Text(
                      vehicle.approvalNotes,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem({
    required String title,
    required String subtitle,
    required String url,
    required XFile? localFile,
    required bool isDocument,
  }) {
    final hasPhoto = localFile != null || url.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickImage(isDocument: isDocument),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasPhoto ? AppColors.primaryGold.withValues(alpha: 0.5) : AppColors.cardBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: localFile != null
                    ? Image.file(File(localFile.path), fit: BoxFit.cover)
                    : url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.textMuted,
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted, size: 24),
                          ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhoto ? (localFile != null ? 'Nova foto selecionada' : 'Enviado') : subtitle,
                  style: GoogleFonts.inter(
                    color: hasPhoto ? AppColors.primaryGold : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: hasPhoto ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              hasPhoto ? Icons.edit_outlined : Icons.add_circle_outline,
              color: AppColors.primaryGold,
              size: 22,
            ),
            onPressed: () => _pickImage(isDocument: isDocument),
          ),
        ],
      ),
    );
  }
}