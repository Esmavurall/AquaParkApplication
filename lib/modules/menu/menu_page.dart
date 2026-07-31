import 'package:flutter/material.dart';
import 'package:aquapark/modules/login/login_model.dart';
import 'package:aquapark/modules/dashboard/dashboard_page.dart';
import 'package:aquapark/modules/dailysales/daily_sales_page.dart';
import 'package:aquapark/modules/login/login_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aquapark/core/di/locator.dart';
import 'package:aquapark/core/storage/credential_storage_service.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});


  Future<void> _logout(BuildContext context) async {
    final credentialStorage =
    getIt<CredentialStorageService>();

    await credentialStorage.deletePassword();
    currentUser = null;
    apiUrl = '';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(
          openedAfterLogout: true,
        ),
      ),
      );
  }
  Widget _buildLanguageButton(
      BuildContext context, {
        required Locale locale,
        required String flag,
        required String title,
      }) {
    final bool isSelected = context.locale == locale;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await context.setLocale(locale);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE0F2FE)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00B8D9)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF007C91)
                      : const Color(0xFF475569),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.check_rounded,
                  size: 17,
                  color: Color(0xFF00B8D9),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  void _showSettingsBottomSheet(BuildContext context) {
    final user = currentUser;

    final userName = user?.userName.isNotEmpty == true
        ? user!.userName
        : 'user'.tr();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE0F2FE),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF00B8D9),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          'menu.profile'.tr(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Material(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _logout(context);
                        },
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFDC2626),
                                size: 20,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'menu.logout'.tr(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFFDC2626),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Divider(
                  height: 1,
                  color: Color(0xFFE2E8F0),
                ),

                const SizedBox(height: 18),

                 Row(
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'menu.select_language'.tr(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildLanguageButton(
                      bottomSheetContext,
                      locale: const Locale('tr', 'TR'),
                      flag: '🇹🇷',
                        title: 'menu.turkish'.tr(),
                    ),

                    const SizedBox(width: 10),

                    _buildLanguageButton(
                      bottomSheetContext,
                      locale: const Locale('en', 'US'),
                      flag: '🇺🇸',
                      title: 'menu.english'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final userName = user?.userName.isNotEmpty == true ? user!.userName : 'user'.tr();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
          'app_name'.tr(),
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        backgroundColor: const Color(0xFFF7F8FA),
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              size: 23,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'menu.settings'.tr(),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F2FE), Color(0xFFE6FDF9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFBAE6FD),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B8D9).withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const ClipOval(
                        child: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF00B8D9),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${user?.tenantName.isNotEmpty == true ? '${user!.tenantName}${user.tenantAddress.isNotEmpty ? ' (${user.tenantAddress})' : ''} • ' : ''}${'hotel_id'.tr()}: ${user?.hotelId ?? 0}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 12),
               Text(
                  'quick_actions'.tr(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'quick_actions_description'.tr(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),

              Column(
                children: [
                  _MenuCard(
                    icon: Icons.dashboard_rounded,
                    label: 'dashboard'.tr(),
                    description: 'dashboard_description'.tr(),
                    gradientColors: const [Color(0xFF00B8D9), Color(0xFF006D77)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 21),
                  
                  _MenuCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'daily_sales'.tr(),
                    description: 'daily_sales_description'.tr(),
                    gradientColors: const [Color(0xFF00B8D9), Color(0xFF006D77)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailySalesPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double shadowOpacity = Tween<double>(begin: 0.12, end: 0.04).evaluate(_controller);
        final double shadowBlur = Tween<double>(begin: 28.0, end: 12.0).evaluate(_controller);
        final double shadowOffset = Tween<double>(begin: 10.0, end: 3.0).evaluate(_controller);

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 122,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: shadowOpacity),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowOffset),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 2.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradientColors,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTapDown: (_) => _controller.forward(),
                      onTapCancel: () => _controller.reverse(),
                      onTap: () {
                        _controller.reverse();
                        widget.onTap();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: widget.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: widget.gradientColors.first.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.gradientColors.first.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.label,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4F8DFF),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
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
        );
      },
    );
  }
}
