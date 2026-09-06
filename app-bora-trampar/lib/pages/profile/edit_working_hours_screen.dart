import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';

class EditWorkingHoursScreen extends StatefulWidget {
  final ProfileProfessionalModel proProfile;

  const EditWorkingHoursScreen({
    super.key,
    required this.proProfile,
  });

  @override
  State<EditWorkingHoursScreen> createState() => _EditWorkingHoursScreenState();
}

class _EditWorkingHoursScreenState extends State<EditWorkingHoursScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _daysOfWeek = const [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  late bool _isAvailableNow;
  bool _isSaving = false;
  bool _hasSavedSuccessfully = false;
  bool _showCustomPerDay = false;

  // Mapa de controle por dia: índice -> dados do dia
  late final Map<int, bool> _activeDays;
  late final Map<int, TextEditingController> _startHourControllers;
  late final Map<int, TextEditingController> _endHourControllers;
  late final Map<int, TextEditingController> _breakStartControllers;
  late final Map<int, TextEditingController> _breakEndControllers;

  // Controladores padrão gerais
  late final TextEditingController _generalStartHourController;
  late final TextEditingController _generalEndHourController;
  late final TextEditingController _generalBreakStartController;
  late final TextEditingController _generalBreakEndController;

  @override
  void initState() {
    super.initState();
    _isAvailableNow = widget.proProfile.isAvailableNow;

    _activeDays = {};
    _startHourControllers = {};
    _endHourControllers = {};
    _breakStartControllers = {};
    _breakEndControllers = {};

    final existingHours = widget.proProfile.workingHours;

    // Tentar carregar valores padrão a partir dos existentes
    String initialStart = '08:00';
    String initialEnd = '18:00';
    String initialBreakStart = '12:00';
    String initialBreakEnd = '13:00';

    if (existingHours.isNotEmpty) {
      final firstActive = existingHours.firstWhere(
        (h) => h.isActive,
        orElse: () => existingHours.first,
      );
      initialStart = firstActive.startHour.isNotEmpty ? firstActive.startHour : '08:00';
      initialEnd = firstActive.endHour.isNotEmpty ? firstActive.endHour : '18:00';
      initialBreakStart = firstActive.breakStart.isNotEmpty ? firstActive.breakStart : '12:00';
      initialBreakEnd = firstActive.breakEnd.isNotEmpty ? firstActive.breakEnd : '13:00';
    }

    _generalStartHourController = TextEditingController(text: initialStart);
    _generalEndHourController = TextEditingController(text: initialEnd);
    _generalBreakStartController = TextEditingController(text: initialBreakStart);
    _generalBreakEndController = TextEditingController(text: initialBreakEnd);

    for (int i = 0; i < 7; i++) {
      ProfessionalWorkingDayModel? dayModel;
      try {
        dayModel = existingHours.firstWhere(
          (h) => h.dayOfWeek == i || h.dayName.toLowerCase().startsWith(_daysOfWeek[i].toLowerCase().substring(0, 3)),
        );
      } catch (_) {
        dayModel = null;
      }

      final isActive = dayModel?.isActive ?? (i < 5); // Segunda a Sexta ativo por padrão
      _activeDays[i] = isActive;

      _startHourControllers[i] = TextEditingController(
        text: dayModel?.startHour.isNotEmpty == true ? dayModel!.startHour : initialStart,
      );
      _endHourControllers[i] = TextEditingController(
        text: dayModel?.endHour.isNotEmpty == true ? dayModel!.endHour : initialEnd,
      );
      _breakStartControllers[i] = TextEditingController(
        text: dayModel?.breakStart.isNotEmpty == true ? dayModel!.breakStart : initialBreakStart,
      );
      _breakEndControllers[i] = TextEditingController(
        text: dayModel?.breakEnd.isNotEmpty == true ? dayModel!.breakEnd : initialBreakEnd,
      );
    }

    _generalStartHourController.addListener(() {
      if (!_showCustomPerDay) {
        for (int i = 0; i < 7; i++) {
          _startHourControllers[i]?.text = _generalStartHourController.text;
        }
      }
    });
    _generalEndHourController.addListener(() {
      if (!_showCustomPerDay) {
        for (int i = 0; i < 7; i++) {
          _endHourControllers[i]?.text = _generalEndHourController.text;
        }
      }
    });
    _generalBreakStartController.addListener(() {
      if (!_showCustomPerDay) {
        for (int i = 0; i < 7; i++) {
          _breakStartControllers[i]?.text = _generalBreakStartController.text;
        }
      }
    });
    _generalBreakEndController.addListener(() {
      if (!_showCustomPerDay) {
        for (int i = 0; i < 7; i++) {
          _breakEndControllers[i]?.text = _generalBreakEndController.text;
        }
      }
    });
  }

  @override
  void dispose() {
    _generalStartHourController.dispose();
    _generalEndHourController.dispose();
    _generalBreakStartController.dispose();
    _generalBreakEndController.dispose();

    for (int i = 0; i < 7; i++) {
      _startHourControllers[i]?.dispose();
      _endHourControllers[i]?.dispose();
      _breakStartControllers[i]?.dispose();
      _breakEndControllers[i]?.dispose();
    }
    super.dispose();
  }

  void _applyGeneralHoursToAllDays() {
    final start = _generalStartHourController.text.trim();
    final end = _generalEndHourController.text.trim();
    final bStart = _generalBreakStartController.text.trim();
    final bEnd = _generalBreakEndController.text.trim();

    setState(() {
      for (int i = 0; i < 7; i++) {
        if (start.isNotEmpty) _startHourControllers[i]?.text = start;
        if (end.isNotEmpty) _endHourControllers[i]?.text = end;
        if (bStart.isNotEmpty) _breakStartControllers[i]?.text = bStart;
        if (bEnd.isNotEmpty) _breakEndControllers[i]?.text = bEnd;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Horário padrão aplicado a todos os dias!',
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

    final hasAnyActive = _activeDays.values.any((active) => active);
    if (!hasAnyActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecione pelo menos um dia da semana para atendimento.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final genStart = _generalStartHourController.text.trim().isNotEmpty ? _generalStartHourController.text.trim() : '08:00';
      final genEnd = _generalEndHourController.text.trim().isNotEmpty ? _generalEndHourController.text.trim() : '18:00';
      final genBStart = _generalBreakStartController.text.trim().isNotEmpty ? _generalBreakStartController.text.trim() : '12:00';
      final genBEnd = _generalBreakEndController.text.trim().isNotEmpty ? _generalBreakEndController.text.trim() : '13:00';

      final workingHoursList = List.generate(7, (i) {
        final isActive = _activeDays[i] ?? false;
        final start = (_showCustomPerDay && _startHourControllers[i]?.text.trim().isNotEmpty == true)
            ? _startHourControllers[i]!.text.trim()
            : genStart;
        final end = (_showCustomPerDay && _endHourControllers[i]?.text.trim().isNotEmpty == true)
            ? _endHourControllers[i]!.text.trim()
            : genEnd;
        final bStart = (_showCustomPerDay && _breakStartControllers[i]?.text.trim().isNotEmpty == true)
            ? _breakStartControllers[i]!.text.trim()
            : genBStart;
        final bEnd = (_showCustomPerDay && _breakEndControllers[i]?.text.trim().isNotEmpty == true)
            ? _breakEndControllers[i]!.text.trim()
            : genBEnd;

        return ProfessionalWorkingDayModel(
          dayOfWeek: i,
          dayName: _daysOfWeek[i],
          isActive: isActive,
          startHour: start,
          endHour: end,
          breakStart: bStart,
          breakEnd: bEnd,
        );
      });

      debugPrint('[EditWorkingHoursScreen] Salvando profile com ${workingHoursList.length} dias:');
      for (final w in workingHoursList) {
        debugPrint('  -> ${w.dayName}: active=${w.isActive}, ${w.startHour}-${w.endHour} (almoço: ${w.breakStart}-${w.breakEnd})');
      }

      final updatedProfile = widget.proProfile.copyWith(
        isAvailableNow: _isAvailableNow,
        workingHours: workingHoursList,
      );

      final result = await ProfileProfessionalRepository().saveProfile(updatedProfile);

      if (_hasSavedSuccessfully) return;

      if (result != null && mounted) {
        _hasSavedSuccessfully = true;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Horários de disponibilidade salvos com sucesso!',
              style: GoogleFonts.inter(color: AppColors.textDark, fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primaryGold,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(result);
        return;
      } else {
        if (mounted && !_hasSavedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível salvar os horários. Tente novamente.',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted && !_hasSavedSuccessfully) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar horários de atendimento.',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
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
          'Horários de Atendimento',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
              _buildAvailabilityNowSwitch(),
              const SizedBox(height: 18),
              _buildDaysSelectionCard(),
              const SizedBox(height: 18),
              _buildGeneralScheduleCard(),
              const SizedBox(height: 18),
              _buildPerDayCustomizationCard(),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Salvar Horários',
                isLoading: _isSaving,
                onPressed: (_isSaving || _hasSavedSuccessfully) ? null : _handleSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityNowSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Row(
                  children: [
                    Icon(
                      _isAvailableNow ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _isAvailableNow ? AppColors.primaryGold : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Disponível Agora',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isAvailableNow
                      ? 'Você aparece como disponível para chamados imediatos.'
                      : 'Você não aparecerá como disponível para novos pedidos imediatos.',
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

  Widget _buildDaysSelectionCard() {
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
            'Dias da Semana Disponíveis',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque para ativar ou desativar os dias em que você trabalha.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final isSelected = _activeDays[i] ?? false;
              return ChoiceChip(
                label: Text(_daysOfWeek[i]),
                selected: isSelected,
                selectedColor: AppColors.primaryGold,
                backgroundColor: AppColors.cardElevated,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) => setState(() => _activeDays[i] = val),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralScheduleCard() {
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
                'Horário Geral de Trabalho',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Aplicar a todos os dias',
                icon: const Icon(Icons.sync_rounded, color: AppColors.primaryGold, size: 20),
                onPressed: _applyGeneralHoursToAllDays,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Defina o horário padrão de início, término e pausa de almoço.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  controller: _generalStartHourController,
                  label: 'Início',
                  hint: '08:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  controller: _generalEndHourController,
                  label: 'Término',
                  hint: '18:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  controller: _generalBreakStartController,
                  label: 'Almoço Início',
                  hint: '12:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  controller: _generalBreakEndController,
                  label: 'Almoço Fim',
                  hint: '13:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _applyGeneralHoursToAllDays,
              icon: const Icon(Icons.copy_rounded, color: AppColors.primaryGold, size: 16),
              label: Text(
                'Aplicar este horário a todos os dias',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerDayCustomizationCard() {
    return Material(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _showCustomPerDay,
          onExpansionChanged: (val) => setState(() => _showCustomPerDay = val),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.tune_rounded, color: AppColors.primaryGold, size: 20),
          title: Text(
            'Personalizar Horário por Dia',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Ajuste horários específicos para dias pontuais',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          children: [
            const Divider(color: AppColors.cardBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(7, (i) {
                  final isActive = _activeDays[i] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.primaryGold.withValues(alpha: 0.3) : AppColors.cardBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _daysOfWeek[i],
                              style: GoogleFonts.inter(
                                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Switch(
                              value: isActive,
                              activeThumbColor: AppColors.primaryGold,
                              activeTrackColor: AppColors.primaryGold.withValues(alpha: 0.4),
                              inactiveThumbColor: AppColors.textMuted,
                              inactiveTrackColor: AppColors.cardBorder,
                              onChanged: (val) {
                                setState(() => _activeDays[i] = val);
                              },
                            ),
                          ],
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeField(
                                  controller: _startHourControllers[i]!,
                                  label: 'Início',
                                  hint: '08:00',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTimeField(
                                  controller: _endHourControllers[i]!,
                                  label: 'Fim',
                                  hint: '18:00',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeField(
                                  controller: _breakStartControllers[i]!,
                                  label: 'Almoço Início',
                                  hint: '12:00',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTimeField(
                                  controller: _breakEndControllers[i]!,
                                  label: 'Almoço Fim',
                                  hint: '13:00',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        HoraInputFormatter(),
      ],
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Informe';
        if (val.trim().length != 5) return '00:00';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }
}
