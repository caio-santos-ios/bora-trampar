import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/category_model.dart';
import '../../models/profile_professional_model.dart';
import '../../models/service_item_model.dart';
import '../../models/user_model.dart';
import '../../repositories/category/category_repository.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/services/services_repository.dart';
import '../../repositories/user/user_repository.dart';
import 'edit_professional_address_screen.dart';

class EditProfessionalProfileScreen extends StatefulWidget {
  final UserModel user;
  final ProfileProfessionalModel? proProfile;

  const EditProfessionalProfileScreen({
    super.key,
    required this.user,
    this.proProfile,
  });

  @override
  State<EditProfessionalProfileScreen> createState() =>
      _EditProfessionalProfileScreenState();
}

class _EditProfessionalProfileScreenState
    extends State<EditProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _professionController;
  late final TextEditingController _bioController;

  int _experienceYears = 0;
  bool _isAvailableNow = true;
  List<ProfessionalServiceItemModel> _services = [];
  late ProfessionalAddressModel _currentAddress;

  bool _isSaving = false;
  bool _hasSavedSuccessfully = false;

  List<CategoryModel> _availableCategories = [];
  CategoryModel? _selectedCategoryForAdd;
  List<ServiceItemModel> _availableServices = [];
  ServiceItemModel? _selectedServiceForAdd;
  final TextEditingController _servicePriceController = TextEditingController(
    text: '150',
  );
  String _servicePriceType = 'Diária';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _whatsappController = TextEditingController(
      text: widget.user.whatsapp ?? '',
    );
    _professionController = TextEditingController(
      text: widget.proProfile?.profession ?? '',
    );
    _bioController = TextEditingController(text: widget.proProfile?.bio ?? '');
    _experienceYears = widget.proProfile?.experienceYears ?? 0;
    _isAvailableNow = widget.proProfile?.isAvailableNow ?? true;
    _services = List<ProfessionalServiceItemModel>.from(
      widget.proProfile?.services ?? [],
    );
    _currentAddress =
        widget.proProfile?.address ??
        ProfessionalAddressModel(
          location: ProfessionalAddressLocationModel.empty(),
        );

    _loadCatalog();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final cats = await CategoryRepository().getCategories();
      final allCats = cats.isNotEmpty ? cats : await CategoryRepository().get();

      if (mounted) {
        setState(() {
          _availableCategories = allCats;
          if (_availableCategories.isNotEmpty) {
            _selectedCategoryForAdd = _availableCategories.first;
          }
        });
        if (_selectedCategoryForAdd != null) {
          await _loadServicesForCategory(_selectedCategoryForAdd!.id);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadServicesForCategory(String categoryId) async {
    try {
      final sList = await ServicesRepository().getServices(
        categoryId: categoryId,
      );
      if (mounted) {
        setState(() {
          _availableServices = sList;
          if (_availableServices.isNotEmpty) {
            _selectedServiceForAdd = _availableServices.first;
            _servicePriceController.text = _selectedServiceForAdd!.basePrice
                .toStringAsFixed(0);
          } else {
            _selectedServiceForAdd = null;
          }
        });
      }
    } catch (_) {}
  }

  void _addService() {
    if (_selectedServiceForAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecione um serviço para adicionar.',
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

    final isAlreadyAdded = _services.any(
      (s) =>
          (s.serviceId.isNotEmpty &&
              s.serviceId == _selectedServiceForAdd!.id) ||
          s.serviceName.trim().toLowerCase() ==
              _selectedServiceForAdd!.name.trim().toLowerCase(),
    );
    if (isAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Este serviço já foi adicionado na sua lista.',
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

    double price = 0.0;
    try {
      price = UtilBrasilFields.converterMoedaParaDouble(
        _servicePriceController.text,
      );
    } catch (_) {
      price =
          double.tryParse(
            _servicePriceController.text
                .replaceAll("R\$", "")
                .replaceAll(".", "")
                .replaceAll(",", ".")
                .trim(),
          ) ??
          0.0;
    }
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
      _services.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Serviço adicionado com sucesso!',
          style: GoogleFonts.inter(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_isSaving || _hasSavedSuccessfully) return;

    if (!_formKey.currentState!.validate()) return;

    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adicione pelo menos um serviço ao seu perfil.',
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

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final whatsapp = _whatsappController.text.trim();
      final profession = _professionController.text.trim();
      final bio = _bioController.text.trim();

      // 1. Atualizar dados do User
      await UserRepository().updateUser(
        id: widget.user.id,
        name: name,
        email: email,
        whatsapp: whatsapp,
      );

      // 2. Atualizar dados do ProfileProfessional
      final baseProfile =
          widget.proProfile ??
          ProfileProfessionalModel(
            userId: widget.user.id,
            profession: profession,
            bio: bio,
            address: _currentAddress,
          );

      final updatedProfile = baseProfile.copyWith(
        profession: profession,
        bio: bio,
        experienceYears: _experienceYears,
        isAvailableNow: _isAvailableNow,
        isProfileCompleted: true,
        address: _currentAddress,
        services: _services,
      );

      await ProfileProfessionalRepository().saveProfile(updatedProfile);

      if (_hasSavedSuccessfully) return;

      // 3. Atualizar armazenamento local
      final updatedUser = widget.user.copyWith(
        name: name,
        email: email,
        whatsapp: whatsapp,
      );

      await StorageService.setUser(updatedUser.toJson());

      if (mounted) {
        _hasSavedSuccessfully = true;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perfil atualizado com sucesso!',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
        return;
      }
    } catch (e) {
      if (mounted && !_hasSavedSuccessfully) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar alterações. Tente novamente.',
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
      if (mounted && !_hasSavedSuccessfully) {
        setState(() => _isSaving = false);
      }
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
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Editar Perfil Profissional',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildSectionTitle(
                'Dados da Conta',
                Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe seu nome completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe seu e-mail';
                  }
                  if (!val.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _whatsappController,
                label: 'WhatsApp / Telefone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter(),
                ],
              ),
              const SizedBox(height: 28),
              _buildSectionTitle(
                'Dados Profissionais',
                Icons.work_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _professionController,
                label: 'Profissão / Especialidade',
                icon: Icons.badge_outlined,
                hint: 'Ex: Eletricista Residencial, Encanador...',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe sua profissão';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildExperienceSlider(),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _bioController,
                label: 'Biografia / Apresentação',
                icon: Icons.description_outlined,
                hint:
                    'Conte aos clientes sobre sua experiência e diferenciais...',
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              _buildAvailabilitySwitch(),
              const SizedBox(height: 28),
              _buildSectionTitle(
                'Endereço & Raio de Atuação',
                Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _buildAddressSection(),
              const SizedBox(height: 28),
              _buildSectionTitle(
                'Meus Serviços & Preços',
                Icons.miscellaneous_services_rounded,
              ),
              const SizedBox(height: 12),
              _buildAddServiceBox(),
              const SizedBox(height: 20),
              _buildServicesList(),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Salvar Alterações',
                isLoading: _isSaving,
                onPressed: (_isSaving || _hasSavedSuccessfully)
                    ? null
                    : _handleSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final addr = _currentAddress;
    final hasAddress =
        addr.street.isNotEmpty ||
        addr.city.isNotEmpty ||
        addr.neighborhood.isNotEmpty;
    final addressText = hasAddress
        ? [
            if (addr.street.isNotEmpty)
              '${addr.street}${addr.number.isNotEmpty ? ', ${addr.number}' : ''}',
            if (addr.neighborhood.isNotEmpty) addr.neighborhood,
            [addr.city, addr.state].where((s) => s.isNotEmpty).join(', '),
          ].where((s) => s.isNotEmpty).join(' - ')
        : 'Nenhum endereço cadastrado';

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pin_drop_rounded,
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
                      addressText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Raio de atendimento: ${addr.serviceRadiusKm > 0 ? addr.serviceRadiusKm : 25} km',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final baseProfile =
                    widget.proProfile ??
                    ProfileProfessionalModel(
                      userId: widget.user.id,
                      profession: _professionController.text.trim(),
                      bio: _bioController.text.trim(),
                      address: _currentAddress,
                    );
                final updated = await Navigator.of(context).push<dynamic>(
                  MaterialPageRoute(
                    builder: (_) => EditProfessionalAddressScreen(
                      proProfile: baseProfile.copyWith(
                        address: _currentAddress,
                      ),
                    ),
                  ),
                );
                if (updated is ProfileProfessionalModel) {
                  setState(() {
                    _currentAddress = updated.address;
                  });
                }
              },
              icon: const Icon(
                Icons.edit_location_alt_outlined,
                size: 18,
                color: AppColors.primaryGold,
              ),
              label: Text(
                'Alterar Endereço e Raio',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryGold,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tempo de Experiência',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _experienceYears == 0
                    ? 'Iniciante'
                    : '$_experienceYears ${_experienceYears == 1 ? 'ano' : 'anos'}',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: _experienceYears.toDouble(),
            min: 0,
            max: 30,
            divisions: 30,
            activeColor: AppColors.primaryGold,
            inactiveColor: AppColors.cardBorder,
            onChanged: (val) {
              setState(() => _experienceYears = val.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disponível Agora',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailableNow
                      ? 'Seu perfil aparecerá nas buscas imediatas'
                      : 'Você não aparecerá como disponível para novos pedidos',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailableNow,
            activeThumbColor: AppColors.primaryGold,
            activeTrackColor: AppColors.primaryGold.withValues(alpha: 0.4),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.cardBorder,
            onChanged: (val) {
              setState(() => _isAvailableNow = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddServiceBox() {
    return Container(
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
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (_availableCategories.isNotEmpty)
            DropdownButtonFormField<CategoryModel>(
              key: ValueKey('cat_${_availableCategories.length}'),
              initialValue: _selectedCategoryForAdd,
              dropdownColor: AppColors.cardBackground,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: _availableCategories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.title));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategoryForAdd = val);
                if (val != null) {
                  _loadServicesForCategory(val.id);
                }
              },
            ),
          const SizedBox(height: 10),
          if (_availableServices.isNotEmpty)
            DropdownButtonFormField<ServiceItemModel>(
              key: ValueKey(
                'serv_${_selectedCategoryForAdd?.id}_${_availableServices.length}',
              ),
              initialValue: _selectedServiceForAdd,
              dropdownColor: AppColors.cardBackground,
              decoration: const InputDecoration(labelText: 'Serviço'),
              items: _availableServices.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.name));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedServiceForAdd = val;
                  if (val != null) {
                    _servicePriceController.text = val.basePrice
                        .toStringAsFixed(0);
                  }
                });
              },
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CentavosInputFormatter(moeda: true),
                  ],
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
                    DropdownMenuItem(
                      value: 'Por Hora',
                      child: Text('Por Hora'),
                    ),
                    DropdownMenuItem(value: 'Fixo', child: Text('Valor Fixo')),
                  ],
                  onChanged: (val) =>
                      setState(() => _servicePriceType = val ?? 'Diária'),
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
              label: Text(
                'Adicionar à Minha Lista',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seus Serviços Cadastrados (${_services.length})',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (_services.isEmpty)
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
            children: _services.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                          Text(
                            s.serviceName,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${s.categoryName} • ${s.priceType}',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      UtilBrasilFields.obterReal(s.price),
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.errorRed,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _services.remove(s)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
