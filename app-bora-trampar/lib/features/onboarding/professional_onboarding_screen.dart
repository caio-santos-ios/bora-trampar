import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/category_model.dart';
import '../../data/models/profile/profile_professional_model.dart';
import '../../data/models/service_item_model.dart';
import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/profile/profile_professional_repository.dart';
import '../../data/repositories/services/services_repository.dart';
import '../../data/repositories/upload/upload_repository.dart';
import 'identity_verification_pending_screen.dart';

class ProfessionalOnboardingScreen extends StatefulWidget {
  const ProfessionalOnboardingScreen({super.key});

  @override
  State<ProfessionalOnboardingScreen> createState() => _ProfessionalOnboardingScreenState();
}

class _ProfessionalOnboardingScreenState extends State<ProfessionalOnboardingScreen> {
  final ProfileProfessionalRepository _profileRepo = ProfileProfessionalRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final ServicesRepository _serviceRepo = ServicesRepository();
  final UploadRepository _uploadRepo = UploadRepository();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 1;
  final int _totalSteps = 5;
  bool _isLoading = false;
  bool _isSearchingCep = false;

  String _docType = 'CNH';
  final TextEditingController _docNumberController = TextEditingController();
  XFile? _docFrontPhoto;
  XFile? _docBackPhoto;
  XFile? _docSelfiePhoto;

  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  int _experienceYears = 3;

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'São Paulo');
  final TextEditingController _stateController = TextEditingController(text: 'SP');
  double _serviceRadiusKm = 25.0;

  List<CategoryModel> _availableCategories = [];
  List<ServiceItemModel> _availableServices = [];
  final List<ProfessionalServiceItemModel> _selectedServices = [];
  CategoryModel? _selectedCategoryForAdd;
  ServiceItemModel? _selectedServiceForAdd;
  final TextEditingController _servicePriceController = TextEditingController(text: '200');
  String _servicePriceType = 'Diária';

  final List<String> _daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  final Map<int, bool> _activeDays = {0: true, 1: true, 2: true, 3: true, 4: true, 5: true, 6: false};
  final TextEditingController _startHourController = TextEditingController(text: '08:00');
  final TextEditingController _endHourController = TextEditingController(text: '18:00');
  final TextEditingController _breakStartController = TextEditingController(text: '12:00');
  final TextEditingController _breakEndController = TextEditingController(text: '13:00');
  bool _isStepLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _servicePriceController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    _breakStartController.dispose();
    _breakEndController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final categories = await _categoryRepo.getCategories();
    final services = await _serviceRepo.getServices();

    if (mounted) {
      setState(() {
        _availableCategories = categories;
        _availableServices = services;
        if (categories.isNotEmpty) _selectedCategoryForAdd = categories.first;
        if (services.isNotEmpty) _selectedServiceForAdd = services.first;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchViaCep(String rawCep) async {
    final cleanCep = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return;

    setState(() => _isSearchingCep = true);

    try {
      final dio = Dio();
      final response = await dio.get('https://viacep.com.br/ws/$cleanCep/json/');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['erro'] != true && data['erro'] != 'true') {
          setState(() {
            _streetController.text = data['logradouro']?.toString() ?? '';
            _neighborhoodController.text = data['bairro']?.toString() ?? '';
            _cityController.text = data['localidade']?.toString() ?? 'São Paulo';
            _stateController.text = data['uf']?.toString() ?? 'SP';
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSearchingCep = false);
    }
  }

  Future<void> _pickImage(int type) async {
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
                  title: const Text('Câmera', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGold),
                  title: const Text('Galeria', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null && mounted) {
        setState(() {
          if (type == 1) _docFrontPhoto = picked;
          if (type == 2) _docBackPhoto = picked;
          if (type == 3) _docSelfiePhoto = picked;
        });
      }
    }
  }

  void _addService() {
    if (_selectedServiceForAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecione um serviço para adicionar.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final isAlreadyAdded = _selectedServices.any((s) => s.serviceId == _selectedServiceForAdd!.id);
    if (isAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Este serviço já foi adicionado na sua lista.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final price = double.tryParse(_servicePriceController.text.replaceAll(',', '.')) ?? 200.0;
    final item = ProfessionalServiceItemModel(
      categoryId: _selectedCategoryForAdd?.id ?? '',
      categoryName: _selectedCategoryForAdd?.title ?? 'Serviço',
      serviceId: _selectedServiceForAdd?.id ?? '',
      serviceName: _selectedServiceForAdd?.name ?? 'Diária',
      price: price,
      priceType: _servicePriceType,
      estimatedMinutes: _servicePriceType == 'Diária' ? 480 : 120,
      description: 'Atendimento profissional de qualidade.',
    );

    setState(() {
      _selectedServices.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Serviço adicionado com sucesso!',
          style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  Future<void> _submitOnboarding() async {
    final user = await AuthService().getCurrentUser();
    final userId = (user?.id != null && user!.id.isNotEmpty) ? user.id : '';

    setState(() => _isLoading = true);

    String frontUrl = '';
    String backUrl = '';
    String selfieUrl = '';

    if (_docFrontPhoto != null) {
      frontUrl = await _uploadRepo.uploadImage(File(_docFrontPhoto!.path), folder: 'kyc') ?? '';
    }
    if (_docBackPhoto != null) {
      backUrl = await _uploadRepo.uploadImage(File(_docBackPhoto!.path), folder: 'kyc') ?? '';
    }
    if (_docSelfiePhoto != null) {
      selfieUrl = await _uploadRepo.uploadImage(File(_docSelfiePhoto!.path), folder: 'kyc') ?? '';
    }

    final workingHoursList = List.generate(7, (i) {
      return ProfessionalWorkingDayModel(
        dayOfWeek: i,
        dayName: _daysOfWeek[i],
        isActive: _activeDays[i] ?? false,
        startHour: _startHourController.text.trim().isNotEmpty ? _startHourController.text.trim() : '08:00',
        endHour: _endHourController.text.trim().isNotEmpty ? _endHourController.text.trim() : '18:00',
        breakStart: _breakStartController.text.trim().isNotEmpty ? _breakStartController.text.trim() : '12:00',
        breakEnd: _breakEndController.text.trim().isNotEmpty ? _breakEndController.text.trim() : '13:00',
      );
    });

    final address = ProfessionalAddressModel(
      zipCode: _cepController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      complement: _complementController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'São Paulo',
      state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'SP',
      serviceRadiusKm: _serviceRadiusKm.round(),
    );

    final profile = ProfileProfessionalModel(
      userId: userId,
      profession: _professionController.text.trim().isNotEmpty
          ? _professionController.text.trim()
          : 'Profissional Especialista',
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : 'Profissional autônomo qualificado.',
      experienceYears: _experienceYears,
      isAvailableNow: true,
      isProfileCompleted: true,
      identityDocumentType: _docType,
      identityDocumentNumber: _docNumberController.text.trim(),
      identityDocumentFrontUrl: frontUrl,
      identityDocumentBackUrl: backUrl,
      identitySelfieUrl: selfieUrl,
      identityVerificationStatus: 'Pending',
      address: address,
      services: _selectedServices.isNotEmpty
          ? _selectedServices
          : [
              ProfessionalServiceItemModel(
                categoryId: _selectedCategoryForAdd?.id ?? (_availableCategories.isNotEmpty ? _availableCategories.first.id : 'cat_geral'),
                categoryName: _selectedCategoryForAdd?.title ?? (_availableCategories.isNotEmpty ? _availableCategories.first.title : 'Geral'),
                serviceId: _selectedServiceForAdd?.id ?? (_availableServices.isNotEmpty ? _availableServices.first.id : 'serv_diaria'),
                serviceName: _selectedServiceForAdd?.name ?? (_professionController.text.trim().isNotEmpty ? _professionController.text.trim() : 'Diária de Serviço'),
                price: double.tryParse(_servicePriceController.text.replaceAll(',', '.')) ?? 200.0,
                priceType: _servicePriceType,
              )
            ],
      workingHours: workingHoursList,
      badges: const ['Cadastro Completo'],
    );

    final saved = await _profileRepo.saveProfile(profile);

    if (mounted) {
      setState(() => _isLoading = false);

      if (saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perfil e Documentos enviados com sucesso! Seus dados estão em análise.',
              style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primaryGold,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => IdentityVerificationPendingScreen(initialProfile: saved)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível salvar o perfil. Tente novamente.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _nextStep() async {
    if (_isStepLoading || _isLoading) return;

    if (_currentStep == 1) {
      if (_docNumberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, informe o número do documento.')),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps) {
      setState(() => _isStepLoading = true);
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _currentStep++;
        _isStepLoading = false;
      });
    } else {
      _submitOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Cadastro do Profissional',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: BoraTrampaLogo(size: 28, showSubtitle: false, isHorizontal: false),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Etapa $_currentStep de $_totalSteps',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _getStepTitle(_currentStep),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    backgroundColor: AppColors.cardBackground,
                    color: AppColors.primaryGold,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        if (_currentStep == 1) _buildStep1Identity(),
                        if (_currentStep == 2) _buildStep2ProfessionalInfo(),
                        if (_currentStep == 3) _buildStep3Address(),
                        if (_currentStep == 4) _buildStep4Services(),
                        if (_currentStep == 5) _buildStep5Schedule(),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: PrimaryButton(
                text: _currentStep == _totalSteps ? 'Finalizar Cadastro' : 'Continuar',
                isLoading: _currentStep < _totalSteps && _isStepLoading,
                onPressed: (_isLoading || _isStepLoading) ? null : _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Validação de Identidade';
      case 2:
        return 'Dados Profissionais';
      case 3:
        return 'Endereço & Raio';
      case 4:
        return 'Serviços & Preços';
      case 5:
        return 'Horários de Atendimento';
      default:
        return '';
    }
  }

  Widget _buildStep1Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validação de Identidade (KYC)',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Para garantir a segurança dos clientes e profissionais, precisamos validar seu documento oficial.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('CNH Digital / Física')),
                selected: _docType == 'CNH',
                selectedColor: AppColors.primaryGold,
                labelStyle: GoogleFonts.inter(
                  color: _docType == 'CNH' ? AppColors.textDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => setState(() => _docType = 'CNH'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('RG Oficial')),
                selected: _docType == 'RG',
                selectedColor: AppColors.primaryGold,
                labelStyle: GoogleFonts.inter(
                  color: _docType == 'RG' ? AppColors.textDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => setState(() => _docType = 'RG'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _docNumberController,
          keyboardType: _docType == 'CNH' ? TextInputType.number : TextInputType.text,
          inputFormatters: _docType == 'CNH'
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ]
              : null,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: _docType == 'CNH' ? 'CPF do Titular' : 'Número do RG',
            labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Fotos do Documento',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildPhotoUploadSlot('Frente do Documento', _docFrontPhoto, () => _pickImage(1))),
            const SizedBox(width: 12),
            Expanded(child: _buildPhotoUploadSlot('Verso do Documento', _docBackPhoto, () => _pickImage(2))),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Selfie com o Documento',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Tire uma foto do seu rosto segurando o documento ao lado.',
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _buildPhotoUploadSlot('Selfie segurando o documento', _docSelfiePhoto, () => _pickImage(3), height: 140),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSlot(String label, XFile? file, VoidCallback onTap, {double height = 90}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.primaryGold : AppColors.cardBorder,
            width: file != null ? 1.5 : 1,
          ),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: AppColors.primaryGold, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStep2ProfessionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua Especialidade & Experiência',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Como você gostaria que os clientes te encontrassem no app?',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _professionController,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Profissão / Especialidade Principal',
            hintText: 'Ex: Eletricista Residencial, Pedreiro, etc.',
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Tempo de Experiência: $_experienceYears anos',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Slider(
          value: _experienceYears.toDouble(),
          min: 0,
          max: 30,
          divisions: 30,
          activeColor: AppColors.primaryGold,
          onChanged: (val) => setState(() => _experienceYears = val.round()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          maxLines: 4,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Sobre você e seus serviços',
            hintText: 'Conte um pouco sobre sua experiência, cuidados e pontualidade...',
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localização & Raio de Atuação',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Defina seu ponto de partida e até qual distância você aceita receber chamados.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
                onChanged: (val) {
                  if (val.replaceAll(RegExp(r'\D'), '').length == 8) {
                    _fetchViaCep(val);
                  }
                },
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: _isSearchingCep
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _neighborhoodController,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _streetController,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Rua / Logradouro',
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _numberController,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Número',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _cityController,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raio de Atendimento',
                    style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Até ${_serviceRadiusKm.round()} km',
                    style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              Slider(
                value: _serviceRadiusKm,
                min: 5,
                max: 60,
                divisions: 11,
                activeColor: AppColors.primaryGold,
                onChanged: (val) => setState(() => _serviceRadiusKm = val),
              ),
              Text(
                'Você receberá solicitações de clientes localizados a até ${_serviceRadiusKm.round()} km do seu endereço.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Services() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Serviços & Tabela de Preços',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Adicione os serviços que você realiza e defina seus valores padrão.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Novo Serviço',
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (_availableCategories.isNotEmpty)
                DropdownButtonFormField<CategoryModel>(
                  initialValue: _selectedCategoryForAdd,
                  dropdownColor: AppColors.cardBackground,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: _availableCategories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.title));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryForAdd = val),
                ),
              const SizedBox(height: 10),
              if (_availableServices.isNotEmpty)
                DropdownButtonFormField<ServiceItemModel>(
                  initialValue: _selectedServiceForAdd,
                  dropdownColor: AppColors.cardBackground,
                  decoration: const InputDecoration(labelText: 'Serviço'),
                  items: _availableServices.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedServiceForAdd = val),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _servicePriceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _servicePriceType,
                      dropdownColor: AppColors.cardBackground,
                      decoration: const InputDecoration(labelText: 'Cobrança'),
                      items: const [
                        DropdownMenuItem(value: 'Diária', child: Text('Diária')),
                        DropdownMenuItem(value: 'Por Hora', child: Text('Por Hora')),
                        DropdownMenuItem(value: 'Fixo', child: Text('Valor Fixo')),
                      ],
                      onChanged: (val) => setState(() => _servicePriceType = val ?? 'Diária'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _addService,
                  icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
                  label: Text('Adicionar à Minha Lista', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Seus Serviços Cadastrados (${_selectedServices.length})',
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (_selectedServices.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Adicione ao menos um serviço para começar a receber chamados.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          Column(
            children: _selectedServices.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.serviceName, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          Text('${s.categoryName} • ${s.priceType}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('R\$ ${s.price.toStringAsFixed(2).replaceAll('.', ',')}', style: GoogleFonts.inter(color: AppColors.primaryGold, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 18),
                      onPressed: () => setState(() => _selectedServices.remove(s)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStep5Schedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horários de Atendimento',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Selecione os dias e horários em que você está disponível para realizar serviços.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Text('Dias da Semana Disponíveis', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final isSelected = _activeDays[i] ?? false;
            return ChoiceChip(
              label: Text(_daysOfWeek[i]),
              selected: isSelected,
              selectedColor: AppColors.primaryGold,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (val) => setState(() => _activeDays[i] = val),
            );
          }),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startHourController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Início',
                        hintText: '08:00',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endHourController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Término',
                        hintText: '18:00',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _breakStartController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Almoço Início',
                        hintText: '12:00',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _breakEndController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Almoço Fim',
                        hintText: '13:00',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
