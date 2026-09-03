import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bora_trampa_logo.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroHeight = (constraints.maxHeight * 0.62).clamp(460.0, 580.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: heroHeight,
                        width: screenWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GoldenWavePainter(),
                              ),
                            ),
                            Positioned(
                              top: 35,
                              bottom: 0,
                              right: -25,
                              child: Image.asset(
                                'assets/images/fundadora.png',
                                fit: BoxFit.fitHeight,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                            Positioned(
                              right: 14,
                              top: heroHeight * 0.44,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gabrieli',
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                  Text(
                                    'Godoi Simões',
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Fundadora do',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      height: 1.15,
                                    ),
                                  ),
                                  Text(
                                    'Bora Trampa',
                                    style: GoogleFonts.inter(
                                      color: AppColors.primaryGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      height: 1.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 12),
                              child: SizedBox(
                                width: screenWidth * 0.54,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BoraTrampaLogo(size: 38),
                                    const SizedBox(height: 18),
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.inter(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w900,
                                          height: 1.12,
                                          color: AppColors.textPrimary,
                                        ),
                                        children: const [
                                          TextSpan(text: 'Trampo por\ndiária, '),
                                          TextSpan(
                                            text: 'do\nseu jeito.',
                                            style: TextStyle(color: AppColors.primaryGold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        'Contrate ou trabalhe com profissionais qualificados de forma rápida, segura e prática.',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildFeatureItem(
                                      icon: Icons.bolt_rounded,
                                      title: 'Rápido',
                                      description: 'Encontre ou seja\nencontrado mais rápido.',
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFeatureItem(
                                      icon: Icons.verified_user_outlined,
                                      title: 'Seguro',
                                      description: 'Perfis verificados e\npagamentos protegidos.',
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFeatureItem(
                                      icon: Icons.groups_outlined,
                                      title: 'Conectado',
                                      description: 'Profissionais e clientes\nperto de você.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildActionButton(
                              title: 'Sou cliente',
                              subtitle: 'Quero contratar um profissional',
                              isPrimary: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(initialRole: 'Customer'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              title: 'Sou profissional',
                              subtitle: 'Quero trabalhar',
                              isPrimary: false,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(initialRole: 'Profissional'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGold, width: 1.5),
            color: Colors.transparent,
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.primaryGold,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
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
              const SizedBox(height: 1),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGold : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: const Color(0xFF242424)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: isPrimary ? AppColors.textDark : AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: isPrimary
                          ? AppColors.textDark.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isPrimary ? AppColors.textDark : AppColors.textPrimary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldenWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFF5B800).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.44);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.46,
      size.width * 0.45, size.height * 0.54,
      size.width, size.height * 0.57,
    );
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFFF5B800).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.46);
    path2.cubicTo(
      size.width * 0.28, size.height * 0.50,
      size.width * 0.52, size.height * 0.59,
      size.width, size.height * 0.63,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
