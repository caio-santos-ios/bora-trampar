import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/profile_professional_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/upload/upload_repository.dart';

class DocumentsVerificationScreen extends StatefulWidget {
  final ProfileProfessionalModel proProfile;

  const DocumentsVerificationScreen({
    super.key,
    required this.proProfile,
  });

  @override
  State<DocumentsVerificationScreen> createState() =>
      _DocumentsVerificationScreenState();
}

class _DocumentsVerificationScreenState
    extends State<DocumentsVerificationScreen> {
  final ProfileProfessionalRepository _profileRepo =
      ProfileProfessionalRepository();
  final UploadRepository _uploadRepo = UploadRepository();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late ProfileProfessionalModel _profile;
  late TextEditingController _docNumberController;
  late String _docType;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasSavedSuccessfully = false;
  bool _isEditing = false;

  XFile? _newFrontPhoto;
  XFile? _newBackPhoto;
  XFile? _newSelfiePhoto;

  @override
  void initState() {
    super.initState();
    _profile = widget.proProfile;
    _docType = _profile.identityDocumentType.isNotEmpty
        ? _profile.identityDocumentType
        : 'CNH';
    _docNumberController = TextEditingController(
      text: _profile.identityDocumentNumber,
    );

    final status = _profile.identityVerificationStatus.toLowerCase().trim();
    if (_profile.identityDocumentFrontUrl.isEmpty ||
        status == 'rejected' ||
        status == 'reject' ||
        status == 'correction') {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    final updated = await _profileRepo.getMe();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (updated != null) {
          _profile = updated;
          _docType = _profile.identityDocumentType.isNotEmpty
              ? _profile.identityDocumentType
              : 'CNH';
          _docNumberController.text = _profile.identityDocumentNumber;
        }
      });
    }
  }

  Future<void> _pickImage(String type) async {
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
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: const Text(
                    'Tirar Foto com a Câmera',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryGold,
                  ),
                  title: const Text(
                    'Escolher da Galeria',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
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
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked != null && mounted) {
        setState(() {
          if (type == 'front') _newFrontPhoto = picked;
          if (type == 'back') _newBackPhoto = picked;
          if (type == 'selfie') _newSelfiePhoto = picked;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível acessar a câmera ou galeria. Verifique as permissões do aplicativo.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _openPhotoZoom(String? url, XFile? localFile, String title) {
    if ((url == null || url.isEmpty) && localFile == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: localFile != null
                      ? Image.file(
                          File(localFile.path),
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          url!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: AppColors.textMuted,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (_isSaving || _hasSavedSuccessfully) return;

    final hasFront =
        _newFrontPhoto != null || _profile.identityDocumentFrontUrl.isNotEmpty;
    final hasBack =
        _newBackPhoto != null || _profile.identityDocumentBackUrl.isNotEmpty;
    final hasSelfie =
        _newSelfiePhoto != null || _profile.identitySelfieUrl.isNotEmpty;

    if (!hasFront || !hasBack || !hasSelfie) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, anexe a frente, o verso e a selfie com o documento.',
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

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String frontUrl = _profile.identityDocumentFrontUrl;
      String backUrl = _profile.identityDocumentBackUrl;
      String selfieUrl = _profile.identitySelfieUrl;

      if (_newFrontPhoto != null) {
        final uploaded = await _uploadRepo.uploadImage(
          File(_newFrontPhoto!.path),
          folder: 'kyc',
        );
        if (uploaded != null && uploaded.isNotEmpty) frontUrl = uploaded;
      }

      if (_newBackPhoto != null) {
        final uploaded = await _uploadRepo.uploadImage(
          File(_newBackPhoto!.path),
          folder: 'kyc',
        );
        if (uploaded != null && uploaded.isNotEmpty) backUrl = uploaded;
      }

      if (_newSelfiePhoto != null) {
        final uploaded = await _uploadRepo.uploadImage(
          File(_newSelfiePhoto!.path),
          folder: 'kyc',
        );
        if (uploaded != null && uploaded.isNotEmpty) selfieUrl = uploaded;
      }

      final docNum = _docNumberController.text.trim();

      final updatedProfile = _profile.copyWith(
        identityDocumentType: _docType,
        identityDocumentNumber: docNum,
        identityDocumentFrontUrl: frontUrl,
        identityDocumentBackUrl: backUrl,
        identitySelfieUrl: selfieUrl,
        identityVerificationStatus: 'Pending',
      );

      final result = await _profileRepo.saveProfile(updatedProfile);

      if (_hasSavedSuccessfully) return;

      if (result != null && mounted) {
        _hasSavedSuccessfully = true;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Documentos enviados com sucesso para análise!',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.primaryGold,
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _profile = result;
          _newFrontPhoto = null;
          _newBackPhoto = null;
          _newSelfiePhoto = null;
          _isEditing = false;
        });

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(_profile);
        }
        return;
      } else {
        if (mounted && !_hasSavedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não foi possível enviar os documentos. Tente novamente.',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
              'Erro ao enviar documentação.',
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

  String _maskDocNumber(String num) {
    if (num.length <= 4) return num;
    final last4 = num.substring(num.length - 4);
    return '•••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final status = _profile.identityVerificationStatus.toLowerCase().trim();
    final isApproved = status == 'approved' || status == 'approve';
    final isRejected = status == 'rejected' || status == 'reject';
    final isCorrection = status == 'correction';

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
          onPressed: () => Navigator.of(context).pop(_profile),
        ),
        title: Text(
          'Documentos & Verificação',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGold,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.primaryGold,
                  ),
            onPressed: _isLoading ? null : _refreshProfile,
            tooltip: 'Atualizar status',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildStatusCard(isApproved, isRejected, isCorrection),
              const SizedBox(height: 20),
              _buildDocumentInfoCard(),
              const SizedBox(height: 20),
              _buildPhotosSection(),
              const SizedBox(height: 28),
              if (_isEditing) ...[
                PrimaryButton(
                  text: 'Salvar e Enviar para Análise',
                  isLoading: _isSaving,
                  onPressed: (_isSaving || _hasSavedSuccessfully)
                      ? null
                      : _handleSave,
                ),
                const SizedBox(height: 12),
                if (_profile.identityDocumentFrontUrl.isNotEmpty)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _newFrontPhoto = null;
                          _newBackPhoto = null;
                          _newSelfiePhoto = null;
                          _docNumberController.text =
                              _profile.identityDocumentNumber;
                        });
                      },
                      child: Text(
                        'Cancelar Alterações',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                if (!isApproved)
                  PrimaryButton(
                    text: 'Atualizar / Reenviar Documentos',
                    icon: Icons.upload_file_rounded,
                    onPressed: () => setState(() => _isEditing = true),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                    label: Text(
                      'Alterar Dados ou Documentos',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    bool isApproved,
    bool isRejected,
    bool isCorrection,
  ) {
    Color badgeBg;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;
    String description;

    if (isApproved) {
      badgeBg = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success.withValues(alpha: 0.5);
      textColor = AppColors.success;
      icon = Icons.verified_rounded;
      title = 'Identidade Verificada';
      description =
          'Sua documentação foi aprovada com sucesso. Seu selo de profissional verificado está ativo para os clientes.';
    } else if (isRejected) {
      badgeBg = AppColors.errorRed.withValues(alpha: 0.15);
      borderColor = AppColors.errorRed.withValues(alpha: 0.5);
      textColor = AppColors.errorRed;
      icon = Icons.cancel_rounded;
      title = 'Documentação Recusada';
      description = _profile.identityVerificationNotes.isNotEmpty
          ? _profile.identityVerificationNotes
          : 'Sua documentação não pôde ser validada. Verifique os dados e reenvie novas fotos legíveis.';
    } else if (isCorrection) {
      badgeBg = Colors.orangeAccent.withValues(alpha: 0.15);
      borderColor = Colors.orangeAccent.withValues(alpha: 0.5);
      textColor = Colors.orangeAccent;
      icon = Icons.error_outline_rounded;
      title = 'Correção Necessária';
      description = _profile.identityVerificationNotes.isNotEmpty
          ? _profile.identityVerificationNotes
          : 'Algumas informações precisam ser corrigidas para que possamos aprovar seu perfil.';
    } else {
      badgeBg = AppColors.primaryGold.withValues(alpha: 0.15);
      borderColor = AppColors.primaryGold.withValues(alpha: 0.5);
      textColor = AppColors.primaryGold;
      icon = Icons.hourglass_top_rounded;
      title = 'Em Análise';
      description =
          'Seus documentos foram recebidos e estão sob análise da nossa moderação. A aprovação ocorre em até 24 horas úteis.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
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
              const Icon(
                Icons.badge_outlined,
                color: AppColors.primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dados do Documento',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditing) ...[
            Text(
              'Tipo de Documento',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDocTypeOption('CNH', 'Carteira de Habilitação'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDocTypeOption('RG', 'Registro Geral'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Número do Documento',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _docNumberController,
              keyboardType: TextInputType.text,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Digite o número do documento',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o número do documento';
                }
                return null;
              },
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipo',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _docType.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: AppColors.primaryGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Número Registrado',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _profile.identityDocumentNumber.isNotEmpty
                      ? _maskDocNumber(_profile.identityDocumentNumber)
                      : 'Não informado',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocTypeOption(String value, String label) {
    final isSelected = _docType == value;
    return GestureDetector(
      onTap: () => setState(() => _docType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: isSelected
                  ? AppColors.primaryGold
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
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
              'Fotos Enviadas',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Toque para ampliar',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildPhotoItem(
          title: 'Frente do Documento',
          subtitle: 'Com foto e dados nítidos',
          url: _profile.identityDocumentFrontUrl,
          localFile: _newFrontPhoto,
          type: 'front',
        ),
        const SizedBox(height: 14),
        _buildPhotoItem(
          title: 'Verso do Documento',
          subtitle: 'Com dados legíveis',
          url: _profile.identityDocumentBackUrl,
          localFile: _newBackPhoto,
          type: 'back',
        ),
        const SizedBox(height: 14),
        _buildPhotoItem(
          title: 'Selfie com Documento',
          subtitle: 'Seu rosto segurando o documento',
          url: _profile.identitySelfieUrl,
          localFile: _newSelfiePhoto,
          type: 'selfie',
        ),
      ],
    );
  }

  Widget _buildPhotoItem({
    required String title,
    required String subtitle,
    required String url,
    required XFile? localFile,
    required String type,
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
            onTap: hasPhoto
                ? () => _openPhotoZoom(url, localFile, title)
                : (_isEditing ? () => _pickImage(type) : null),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasPhoto
                      ? AppColors.primaryGold.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: localFile != null
                    ? Image.file(
                        File(localFile.path),
                        fit: BoxFit.cover,
                      )
                    : url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGold,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: AppColors.textMuted,
                                size: 24,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.textMuted,
                              size: 26,
                            ),
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
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhoto
                      ? (localFile != null
                          ? 'Nova foto selecionada'
                          : 'Documento registrado')
                      : subtitle,
                  style: GoogleFonts.inter(
                    color: hasPhoto
                        ? AppColors.primaryGold
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        hasPhoto ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(
                hasPhoto ? Icons.edit_outlined : Icons.add_circle_outline,
                color: AppColors.primaryGold,
                size: 22,
              ),
              onPressed: () => _pickImage(type),
              tooltip: hasPhoto ? 'Trocar foto' : 'Adicionar foto',
            )
          else if (hasPhoto)
            IconButton(
              icon: const Icon(
                Icons.zoom_in_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => _openPhotoZoom(url, localFile, title),
              tooltip: 'Ver foto',
            ),
        ],
      ),
    );
  }
}
