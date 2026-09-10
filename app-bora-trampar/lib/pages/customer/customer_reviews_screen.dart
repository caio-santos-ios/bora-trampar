import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/core/theme/app_colors.dart';
import 'package:app_bora_trampar/core/widgets/main_app_bar.dart';
import 'package:app_bora_trampar/core/widgets/toastfy_widget.dart';
import 'package:app_bora_trampar/pages/main/main_navigation_screen.dart';
import 'package:app_bora_trampar/repositories/review_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerReviewsScreen extends StatefulWidget {
  final String customerId;
  final String professionalId;
  final String serviceId;
  final String appointmenId;

  const CustomerReviewsScreen({
    super.key,
    required this.customerId,
    required this.professionalId,
    required this.serviceId,
    required this.appointmenId,
  });

  @override
  State<CustomerReviewsScreen> createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  final _reviewRepository = ReviewRepository();

  final _commentController = TextEditingController(text: "");

  bool _isLoadingCreate = false;
  int _selectedRating = 0;

  Future<void> _create() async {
    try {
      setState(() {
        _isLoadingCreate = true;
      });
      Object data = {
        "customerId": widget.customerId,
        "professionalId": widget.professionalId,
        "serviceId": widget.serviceId,
        "appointmentId": widget.appointmenId,
        "point": _selectedRating,
        "comment": _commentController.text,
      };
      
      await _reviewRepository.create(data);

      if (mounted) {
        Toastfy.show(context, "Avaliação feita com sucesso", "success");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(initialIndex: 1),
          ),
        );
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    } finally {
      setState(() {
        _isLoadingCreate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(title: 'Bora Trampa'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 32,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Como foi o serviço?',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      final starValue = index + 1;
                                      final isSelected =
                                          starValue <= _selectedRating;

                                      return GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedRating = starValue,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            transitionBuilder:
                                                (child, animation) =>
                                                    ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              key: ValueKey(isSelected),
                                              size: 40,
                                              color: isSelected
                                                  ? const Color(0xFFFFB800)
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 28),
                                  Stack(
                                    children: [
                                      TextField(
                                        controller: _commentController,
                                        maxLines: 4,
                                        maxLength: 500,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Deixe seu comentário...',
                                          hintStyle: GoogleFonts.inter(
                                            color: AppColors.textMuted,
                                            fontSize: 14,
                                          ),
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
                                          '${_commentController.text.length}/500',
                                          style: GoogleFonts.inter(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _create,
                                      icon: _isLoadingCreate
                                          ? null
                                          : const Icon(
                                              Icons.add_rounded,
                                              color: AppColors.textDark,
                                            ),
                                      label: _isLoadingCreate
                                          ? CircularProgressIndicator()
                                          : Text(
                                              'Enviar Avaliação',
                                              style: GoogleFonts.inter(
                                                color: AppColors.textDark,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
