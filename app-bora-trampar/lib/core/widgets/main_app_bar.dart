import 'package:app_bora_trampar/core/services/storage_service.dart';
import 'package:app_bora_trampar/core/services/util_service.dart';
import 'package:app_bora_trampar/repositories/notification/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/notifications/notifications_screen.dart';
import '../theme/app_colors.dart';
import 'bora_trampa_logo.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const MainAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  String _userName = '';
  String _userPhoto = '';
  int totalNewNotification = 0;
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _onInit();
  }

  Future<void> _onInit() async {
    setState(() {
      _userName = _storageService.getCurrentUser().name;
      _userPhoto = _storageService.getCurrentUser().photo ?? '';
    });
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final list = await _notificationRepository.getNotifications(
        _storageService.getCurrentUser().id,
      );

      if (mounted) {
        setState(() {
          totalNewNotification = list.where((e) => !e.read).length;
        });
      }
    } on DioException catch (err) {
      if (mounted) UtilService.normalizeError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: widget.title == 'Bora Trampa'
          ? const BoraTrampaLogo(size: 28, showSubtitle: false)
          : Text(
              widget.title,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: widget.onProfileTap,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
                color: AppColors.cardElevated,
              ),
              child: ClipOval(
                child: _userPhoto.isNotEmpty
                    ? Image.network(
                        _userPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFallbackAvatar(),
                      )
                    : _buildFallbackAvatar(),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onPressed:
                    widget.onNotificationTap ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
              ),

              if (totalNewNotification > 0) ...[
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar() {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(
          color: AppColors.primaryGold,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
