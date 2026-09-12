import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../repositories/contestation/contestation_repository.dart';
import '../../repositories/upload/upload_repository.dart';

class CustomerCreateContestationScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const CustomerCreateContestationScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<CustomerCreateContestationScreen> createState() =>
      _CustomerCreateContestationScreenState();
}

class _CustomerCreateContestationScreenState
    extends State<CustomerCreateContestationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  final List<String> _reasons = [
    'Serviço não foi realizado',
    'Serviço incompleto ou com defeito',
    'Profissional não compareceu',
    'Cobrança indevida',
    'Outro motivo',
  ];

  late String _selectedReason;
  final List<XFile> _photos = [];
  XFile? _video;

  bool _isSubmitting = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite de 5 fotos atingido.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final source = await _showSourceBottomSheet(
      title: 'Adicionar Foto',
      cameraLabel: 'Tirar Foto com a Câmera',
      galleryLabel: 'Escolher da Galeria',
      isImage: true,
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final remaining = 5 - _photos.length;
        if (remaining > 1) {
          final pickedList = await _picker.pickMultiImage(
            imageQuality: 85,
            limit: remaining,
          );
          if (pickedList.isNotEmpty && mounted) {
            setState(() {
              for (final p in pickedList) {
                if (_photos.length < 5) {
                  _photos.add(p);
                }
              }
            });
            return;
          }
        }
      }

      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          if (_photos.length < 5) {
            _photos.add(picked);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    final source = await _showSourceBottomSheet(
      title: 'Adicionar Vídeo',
      cameraLabel: 'Gravar Vídeo com a Câmera',
      galleryLabel: 'Escolher da Galeria',
      isImage: false,
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );
      if (picked != null && mounted) {
        setState(() {
          _video = picked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar vídeo: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showSourceBottomSheet({
    required String title,
    required String cameraLabel,
    required String galleryLabel,
    required bool isImage,
  }) {
    return showModalBottomSheet<ImageSource>(
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
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    isImage ? Icons.camera_alt_outlined : Icons.videocam_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: Text(
                    cameraLabel,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(
                    isImage
                        ? Icons.photo_library_outlined
                        : Icons.video_library_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: Text(
                    galleryLabel,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitContestation() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, descreva detalhadamente o ocorrido.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadStatus = 'Iniciando envio...';
    });

    try {
      final uploadRepo = UploadRepository();
      final List<String> photoUrls = [];
      String videoUrl = '';

      // 1. Upload de fotos
      for (int i = 0; i < _photos.length; i++) {
        if (!mounted) return;
        setState(() {
          _uploadStatus = 'Enviando foto ${i + 1} de ${_photos.length}...';
        });
        final url = await uploadRepo.uploadImage(
          File(_photos[i].path),
          folder: 'contestations',
        );
        if (url != null && url.isNotEmpty) {
          photoUrls.add(url);
        }
      }

      // 2. Upload de vídeo (se houver)
      if (_video != null) {
        if (!mounted) return;
        setState(() {
          _uploadStatus = 'Enviando vídeo comprobatório...';
        });
        final url = await uploadRepo.uploadVideo(
          File(_video!.path),
          folder: 'contestations',
        );
        if (url != null && url.isNotEmpty) {
          videoUrl = url;
        }
      }

      // 3. Criação da contestação
      if (!mounted) return;
      setState(() {
        _uploadStatus = 'Registrando contestação...';
      });

      final success = await ContestationRepository().createContestation(
        appointmentId: widget.appointment.id,
        reason: _selectedReason,
        description: desc,
        customerEvidenceUrl: photoUrls.isNotEmpty ? photoUrls.first : '',
        photos: photoUrls,
        videoUrl: videoUrl,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contestação registrada com sucesso! O caso foi encaminhado para análise da nossa equipe.',
            ),
            backgroundColor: AppColors.primaryGold,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao registrar contestação. Tente novamente.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar contestação: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    final serviceName = apt.serviceName ?? apt.categoryName ?? 'Serviço Prestado';
    final proName = apt.professionalName?.isNotEmpty == true
        ? apt.professionalName!
        : 'Profissional';
    final priceVal = apt.price ?? 0.0;
    final formattedPrice = UtilBrasilFields.obterReal(priceVal);
    final formattedDate = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(apt.date);

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
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contestar Serviço',
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
              // Card Resumo do Agendamento
              _buildAppointmentCard(
                serviceName: serviceName,
                proName: proName,
                date: formattedDate,
                price: formattedPrice,
              ),

              const SizedBox(height: 16),

              // Aviso sobre o Reembolso / Custódia
              _buildNoticeCard(),

              const SizedBox(height: 24),

              // Campo de Motivo Principal
              Text(
                'Motivo da Contestação *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                dropdownColor: AppColors.cardBackground,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                    borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                  ),
                ),
                items: _reasons.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _selectedReason = val);
                        }
                      },
              ),

              const SizedBox(height: 20),

              // Descrição Detalhada
              Text(
                'Descrição Detalhada do Ocorrido *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Explique claramente o motivo pelo qual você não reconhece a finalização ou solicita o estorno.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                enabled: !_isSubmitting,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Descreva em detalhes o que aconteceu...',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.all(16),
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
                    borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe uma descrição detalhada.';
                  }
                  if (val.trim().length < 10) {
                    return 'A descrição deve ter pelo menos 10 caracteres.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Seção de Fotos (Até 5 fotos)
              _buildPhotosSection(),

              const SizedBox(height: 24),

              // Seção de Vídeo (1 vídeo)
              _buildVideoSection(),

              const SizedBox(height: 32),

              // Botão de Envio
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitContestation,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.report_problem_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  label: Text(
                    _isSubmitting
                        ? (_uploadStatus.isNotEmpty
                            ? _uploadStatus
                            : 'Enviando contestação...')
                        : 'Confirmar e Solicitar Reembolso',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    disabledBackgroundColor: AppColors.errorRed.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String serviceName,
    required String proName,
    required String date,
    required String price,
  }) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                price,
                style: GoogleFonts.inter(
                  color: AppColors.primaryGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Profissional: $proName',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textMuted,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.primaryGold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'O valor pago permanecerá bloqueado com segurança até que a moderação avalie os fatos e documentos anexados para realizar o reembolso.',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos Comprobatórias',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_photos.length}/5 fotos',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _photos.length == 5
                    ? AppColors.primaryGold
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Anexe fotos do local, conversas ou serviços que comprovem sua solicitação (máx. 5).',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._photos.asMap().entries.map((entry) {
              final idx = entry.key;
              final file = entry.value;
              return SizedBox(
                width: 85,
                height: 85,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _isSubmitting
                            ? null
                            : () => setState(() => _photos.removeAt(idx)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (_photos.length < 5)
              GestureDetector(
                onTap: _isSubmitting ? null : _pickPhoto,
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Adicionar',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vídeo Comprobatório',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _video != null ? '1/1 vídeo' : '0/1 vídeo (opcional)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _video != null
                    ? AppColors.primaryGold
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Grave ou selecione um vídeo demonstrativo de até 3 minutos.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        if (_video == null)
          GestureDetector(
            onTap: _isSubmitting ? null : _pickVideo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.video_call_outlined,
                      color: AppColors.primaryGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Anexar Vídeo do Ocorrido',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Câmera ou Galeria',
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.movie_creation_outlined,
                    color: AppColors.primaryGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _video!.name.isNotEmpty
                            ? _video!.name
                            : 'Vídeo anexado',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vídeo pronto para envio',
                        style: GoogleFonts.inter(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.errorRed,
                    size: 22,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() => _video = null),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
