import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/transfer_model.dart';
import '../../repositories/profile/profile_professional_repository.dart';
import '../../repositories/transfer/transfer_repository.dart';

class ProfessionalTransferScreen extends StatefulWidget {
  const ProfessionalTransferScreen({super.key});

  @override
  State<ProfessionalTransferScreen> createState() =>
      _ProfessionalTransferScreenState();
}

class _ProfessionalTransferScreenState
    extends State<ProfessionalTransferScreen> {
  final _transferRepo = TransferRepository();
  final _profileRepo = ProfileProfessionalRepository();

  final _storage = StorageService();

  bool _isLoading = true;
  bool _hideBalance = false;
  double _balance = 0.0;
  String _pixKeyType = '';
  String _pixKey = '';
  List<TransferModel> _transfers = [];

  final List<String> _pixKeyTypes = [
    'CPF',
    'CNPJ',
    'Celular',
    'E-mail',
    'Chave Aleatória',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUser();
    final pro = await _profileRepo.getMe();
    final transfers = await _transferRepo.getMyTransfers();
    print(transfers.length);
    if (mounted) {
      setState(() {
        _balance = user?.walletBalance.toDouble() ?? 0.0;
        _pixKeyType = pro?.pixKeyType ?? '';
        _pixKey = pro?.pixKey ?? '';
        _transfers = transfers;
        _isLoading = false;
      });
    }
  }

  void _showPixKeyModal() {
    String selectedType = _pixKeyType.isNotEmpty ? _pixKeyType : 'CPF';
    final keyController = TextEditingController(text: _pixKey);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<TextInputFormatter> formatters = [];
            TextInputType keyboardType = TextInputType.text;
            String hintText = 'Digite sua chave';

            if (selectedType == 'CPF') {
              formatters = [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
              ];
              keyboardType = TextInputType.number;
              hintText = '000.000.000-00';
            } else if (selectedType == 'CNPJ') {
              formatters = [
                FilteringTextInputFormatter.digitsOnly,
                CnpjInputFormatter(),
              ];
              keyboardType = TextInputType.number;
              hintText = '00.000.000/0000-00';
            } else if (selectedType == 'Celular') {
              formatters = [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneInputFormatter(),
              ];
              keyboardType = TextInputType.phone;
              hintText = '(00) 00000-0000';
            } else if (selectedType == 'E-mail') {
              keyboardType = TextInputType.emailAddress;
              hintText = 'seuemail@exemplo.com';
            } else {
              hintText = 'Cole sua chave aleatória (EVP)';
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 20,
                  right: 20,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _pixKey.isEmpty
                              ? 'Cadastrar Chave PIX'
                              : 'Alterar Chave PIX',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cadastre a chave PIX onde você deseja receber o dinheiro das suas retiradas de saldo.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipo de Chave',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          dropdownColor: AppColors.cardElevated,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryGold,
                          ),
                          items: _pixKeyTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.pix_rounded,
                                    size: 18,
                                    color: AppColors.primaryGold,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    type,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedType = val;
                                keyController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chave PIX',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: keyController,
                      keyboardType: keyboardType,
                      inputFormatters: formatters,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.cardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGold,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.key_rounded,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final text = keyController.text.trim();
                                if (text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Por favor, informe a chave PIX.',
                                      ),
                                      backgroundColor: AppColors.errorRed,
                                    ),
                                  );
                                  return;
                                }

                                final messenger = ScaffoldMessenger.of(context);
                                setModalState(() => isSaving = true);
                                final success = await _transferRepo
                                    .updatePixKey(selectedType, text);
                                setModalState(() => isSaving = false);

                                if (success) {
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  setState(() {
                                    _pixKeyType = selectedType;
                                    _pixKey = text;
                                  });
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Chave PIX salva com sucesso!',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Erro ao salvar chave PIX. Tente novamente.',
                                      ),
                                      backgroundColor: AppColors.errorRed,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textDark,
                                ),
                              )
                            : Text(
                                'Salvar Chave PIX',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawModal() {
    if (_pixKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cadastre uma chave PIX antes de solicitar a retirada.',
          ),
          backgroundColor: AppColors.primaryGold,
          action: SnackBarAction(
            label: 'Cadastrar',
            textColor: AppColors.textDark,
            onPressed: _showPixKeyModal,
          ),
        ),
      );
      _showPixKeyModal();
      return;
    }

    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não possui saldo disponível para retirada.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final amountController = TextEditingController();
    bool isSubmitting = false;

    Future<void> create() async {
      try {
        setState(() {
          isSubmitting = true;
        });

        final text = amountController.text.trim();
        final val = UtilBrasilFields.converterMoedaParaDouble(text);

        await _transferRepo.create({
          'userId': _storage.getCurrentUser().id,
          'amount': val,
          'pixKeyType': _pixKeyType,
          'pixKey': _pixKey,
        });

        if (mounted) {
          Toastfy.show(
            context,
            "Saque solicitado com sucesso, aguardando processamento",
            "success",
          );

          Navigator.pop(context);
          await _loadData();
        }
      } on DioException catch (err) {
        if (mounted) UtilService.normalizeError(context, err);
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 20,
                  right: 20,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solicitar Retirada',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
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
                                'Saldo Disponível',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                UtilBrasilFields.obterReal(_balance),
                                style: GoogleFonts.inter(
                                  color: AppColors.success,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.pix_rounded,
                                color: AppColors.primaryGold,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'PIX ($_pixKeyType): $_pixKey',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Valor da Retirada',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            amountController.text = UtilBrasilFields.obterReal(
                              _balance,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: Text(
                            'Transferir Tudo',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CentavosInputFormatter(moeda: true),
                      ],
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'R\$ 0,00',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: AppColors.cardElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGold,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final text = amountController.text.trim();
                                final val =
                                    UtilBrasilFields.converterMoedaParaDouble(
                                      text,
                                    );

                                if (val <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Informe um valor válido.'),
                                      backgroundColor: AppColors.errorRed,
                                    ),
                                  );
                                  return;
                                }

                                if (val > _balance) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'O valor solicitado é maior que o saldo disponível.',
                                      ),
                                      backgroundColor: AppColors.errorRed,
                                    ),
                                  );
                                  return;
                                }

                                await create();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textDark,
                                ),
                              )
                            : Text(
                                'Confirmar Retirada',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transferência e Saldo',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          : RefreshIndicator(
              color: AppColors.primaryGold,
              backgroundColor: AppColors.cardBackground,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 16),
                  _buildPixKeyCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Histórico de Transferências',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_transfers.length} ${_transfers.length == 1 ? 'registro' : 'registros'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_transfers.isEmpty)
                    _buildEmptyTransfers()
                  else
                    ..._transfers.map(_buildTransferItem),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBackground, AppColors.cardElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Disponível',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                icon: Icon(
                  _hideBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _hideBalance ? 'R\$ ••••••' : UtilBrasilFields.obterReal(_balance),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _showWithdrawModal,
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              label: Text(
                'Solicitar Retirada',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixKeyCard() {
    final hasPix = _pixKey.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pix_rounded,
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
                  hasPix ? 'Chave PIX ($_pixKeyType)' : 'Chave PIX',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasPix ? _pixKey : 'Nenhuma chave cadastrada',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: hasPix
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showPixKeyModal,
            child: Text(
              hasPix ? 'Alterar' : 'Cadastrar',
              style: GoogleFonts.inter(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransfers() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nenhuma transferência ainda',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Quando você solicitar uma retirada de saldo, ela aparecerá aqui com o status de processamento.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransferItem(TransferModel t) {
    Color statusColor = AppColors.primaryGold;
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (t.status.toUpperCase() == 'DONE') {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (t.status.toUpperCase() == 'PENDING') {
      statusColor = AppColors.warning;
      statusIcon = Icons.cancel_rounded;
    } else if (t.status.toUpperCase() == 'CANCELLED' ||
        t.status.toUpperCase() == 'FAILED' ||
        t.status.toUpperCase() == 'REJECTED') {
      statusColor = AppColors.errorRed;
      statusIcon = Icons.cancel_rounded;
    }

    final dateStr = t.createdAt != null
        ? DateFormat("dd/MM/yyyy 'às' HH:mm").format(t.createdAt!.toLocal())
        : 'Data recente';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
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
                      UtilBrasilFields.obterReal(t.amount),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        t.statusLabel,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'PIX ${t.pixKeyType.isNotEmpty ? "(${t.pixKeyType})" : ""}: ${t.pixKey}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
