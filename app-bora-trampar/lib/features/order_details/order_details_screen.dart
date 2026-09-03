import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/order_request_model.dart';
import '../../core/utils/location_helper.dart';
import '../professionals/professionals_list_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const OrderDetailsScreen({super.key, required this.orderRequest});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _useCurrentLocation = true;
  LocationResult? _detectedLocation;
  bool _isLocating = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = 'A partir das 14:00';
  final List<String> _photos = [];

  final List<String> _timeSlots = [
    'A partir das 08:00',
    'A partir das 10:00',
    'A partir das 12:00',
    'A partir das 14:00',
    'A partir das 16:00',
    'A partir das 18:00',
    'Horário comercial',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.orderRequest.description.isNotEmpty) {
      _descController.text = widget.orderRequest.description;
    }
    if (widget.orderRequest.address.isNotEmpty) {
      _addressController.text = widget.orderRequest.address;
    }
    if (widget.orderRequest.notes.isNotEmpty) {
      _notesController.text = widget.orderRequest.notes;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: AppColors.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adicionar Foto do Serviço',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGold),
                    title: Text(
                      'Galeria de Fotos',
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGold),
                    title: Text(
                      'Tirar Foto com a Câmera',
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source != null) {
        final picked = await picker.pickImage(source: source, imageQuality: 80);
        if (picked != null) {
          setState(() {
            _photos.add(picked.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reinicie o aplicativo para sincronizar o plugin de fotos.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.cardElevated,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.textDark,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showTimeSlotModal() {
    showModalBottomSheet(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione o Horário',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final isSelected = slot == _selectedTimeSlot;
                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                          Navigator.of(context).pop();
                        },
                        leading: Icon(
                          Icons.access_time_rounded,
                          color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
                        ),
                        title: Text(
                          slot,
                          style: GoogleFonts.inter(
                            color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primaryGold)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _useCurrentLocation = true;
      _isLocating = true;
    });

    final loc = await LocationHelper.getCurrentLocation();
    if (!mounted) return;

    if (loc != null) {
      setState(() {
        _detectedLocation = loc;
        _isLocating = false;
      });
    } else {
      setState(() {
        _isLocating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível obter a localização GPS. Digite seu endereço.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.cardElevated,
        ),
      );
    }
  }

  Future<void> _onFindProfessionals() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, descreva o que precisa ser feito no serviço.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!_useCurrentLocation && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, informe o endereço onde o serviço será realizado.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLocating = true);

    if (_useCurrentLocation) {
      _detectedLocation ??= await LocationHelper.getCurrentLocation();
      if (_detectedLocation != null) {
        widget.orderRequest.customerLatitude = _detectedLocation!.latitude;
        widget.orderRequest.customerLongitude = _detectedLocation!.longitude;
        widget.orderRequest.customerCity = _detectedLocation!.city;
        widget.orderRequest.customerState = _detectedLocation!.state;
        widget.orderRequest.address = _detectedLocation!.address;
      } else {
        widget.orderRequest.address = 'Localização Atual';
      }
    } else {
      final manualAddr = _addressController.text.trim();
      widget.orderRequest.address = manualAddr;
      final geocoded = await LocationHelper.geocodeAddress(manualAddr);
      if (geocoded != null) {
        widget.orderRequest.customerLatitude = geocoded.latitude;
        widget.orderRequest.customerLongitude = geocoded.longitude;
        widget.orderRequest.customerCity = geocoded.city;
        widget.orderRequest.customerState = geocoded.state;
      }
    }

    if (!mounted) return;
    setState(() => _isLocating = false);

    widget.orderRequest.description = _descController.text.trim();
    widget.orderRequest.notes = _notesController.text.trim();
    widget.orderRequest.useCurrentLocation = _useCurrentLocation;
    widget.orderRequest.scheduledDate = _selectedDate;
    widget.orderRequest.scheduledTimeSlot = _selectedTimeSlot;
    widget.orderRequest.photoPaths = _photos;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfessionalsListScreen(orderRequest: widget.orderRequest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.orderRequest.serviceNamesDisplay;
    final formattedDate = DateFormat("dd 'de' MMMM", 'pt_BR').format(_selectedDate);

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
              child: AppStepper(totalSteps: 4, currentStep: 3),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                children: const [
                                  TextSpan(text: 'Conte mais sobre\no que '),
                                  TextSpan(
                                    text: 'você precisa',
                                    style: TextStyle(color: AppColors.primaryGold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Quanto mais detalhes, mais fácil para o profissional te atender.',
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
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF1F1C12),
                          ),
                          child: const Icon(
                            Icons.foundation_rounded,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName.isNotEmpty ? serviceName : 'Serviço Selecionado',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Você selecionou este serviço.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Alterar serviço',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'O que precisa ser feito?',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        maxLength: 500,
                        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Descreva o serviço que você precisa...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: Text(
                          '${_descController.text.length}/500',
                          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Adicione fotos (opcional)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fotos ajudam o profissional a entender o serviço.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_photos.length < 3)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: _pickPhoto,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryGold.withValues(alpha: 0.8),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        const Icon(
                                          Icons.camera_alt_outlined,
                                          color: AppColors.primaryGold,
                                          size: 26,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primaryGold,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 10,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Adicionar fotos',
                                      style: GoogleFonts.inter(
                                        color: AppColors.primaryGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        for (int i = 0; i < _photos.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Image.file(
                                      File(_photos[i]),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _photos.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        for (int k = _photos.length + (_photos.length < 3 ? 1 : 0); k < 3; k++)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Onde será o serviço?',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _fetchCurrentLocation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _useCurrentLocation ? AppColors.primaryGold : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usar minha localização',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (_isLocating)
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Buscando sinal GPS...',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryGold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (_detectedLocation != null)
                                  Text(
                                    '📍 ${_detectedLocation!.address}',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                else
                                  Text(
                                    'Localize-me automaticamente via GPS',
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _useCurrentLocation ? AppColors.primaryGold : AppColors.cardBorder,
                                width: 2,
                              ),
                            ),
                            child: _useCurrentLocation
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => setState(() => _useCurrentLocation = false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_useCurrentLocation ? AppColors.primaryGold : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.apartment_rounded,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Digite o endereço',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Inserir endereço manualmente',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: !_useCurrentLocation ? AppColors.primaryGold : AppColors.cardBorder,
                                width: 2,
                              ),
                            ),
                            child: !_useCurrentLocation
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_useCurrentLocation) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Rua, número, bairro e cidade...',
                        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quando você precisa?',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColors.primaryGold,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horário',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _showTimeSlotModal,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.primaryGold,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedTimeSlot,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Observações (opcional)',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        maxLength: 300,
                        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Alguma informação importante?',
                          hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: Text(
                          '${_notesController.text.length}/300',
                          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: PrimaryButton(
                text: 'Encontrar profissionais',
                onPressed: _onFindProfessionals,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
