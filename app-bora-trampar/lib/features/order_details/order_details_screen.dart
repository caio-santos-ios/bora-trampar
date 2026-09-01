import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_stepper.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/order_request_model.dart';
import '../professionals/professionals_list_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderRequestModel orderRequest;

  const OrderDetailsScreen({super.key, required this.orderRequest});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TextEditingController _descController = TextEditingController(
    text: 'Preciso levantar uma parede no quintal, aproximadamente 4x3m.',
  );
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(
    text: 'Alameda dos Nhambiquaras, 111 - Moema, São Paulo - SP',
  );

  bool _useCurrentLocation = true;
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
  }

  @override
  void dispose() {
    _descController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
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

  void _onFindProfessionals() {
    widget.orderRequest.description = _descController.text;
    widget.orderRequest.notes = _notesController.text;
    widget.orderRequest.useCurrentLocation = _useCurrentLocation;
    widget.orderRequest.address = _addressController.text;
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
            child: AppStepper(totalSteps: 4, currentStep: 4),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Title + Logo
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
                                TextSpan(text: 'Conte mais sobre\no que você '),
                                TextSpan(
                                  text: 'precisa',
                                  style: TextStyle(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quanto mais detalhes, mais fácil\npara o profissional te atender.',
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

                // Selected Service Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF1F1C12),
                        ),
                        child: const Icon(
                          Icons.foundation_rounded,
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
                              serviceName,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Você selecionou este serviço.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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

                // Section 1: "O que precisa ser feito?"
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

                // Section 2: "Adicione fotos (opcional)"
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
                Row(
                  children: [
                    // Add photo button slot
                    InkWell(
                      onTap: () {
                        setState(() {
                          _photos.add('photo_${_photos.length + 1}');
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto adicionada ao pedido!'),
                            backgroundColor: AppColors.cardElevated,
                          ),
                        );
                      },
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
                    const SizedBox(width: 12),
                    // Placeholder slot 1
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: _photos.isNotEmpty
                          ? const Center(
                              child: Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 28),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Placeholder slot 2
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: _photos.length > 1
                          ? const Center(
                              child: Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 28),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 3: "Onde será o serviço?"
                Text(
                  'Onde será o serviço?',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // Radio 1: Usar minha localização
                InkWell(
                  onTap: () => setState(() => _useCurrentLocation = true),
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
                              Text(
                                'Localize-me automaticamente',
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
                // Radio 2: Digite o endereço
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
                const SizedBox(height: 24),

                // Section 4: Date & Time Pickers
                Row(
                  children: [
                    // Date
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
                    // Time
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

                // Section 5: Observações (opcional)
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

          // Bottom Button: "Encontrar profissionais"
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
    );
  }
}
