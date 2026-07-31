import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:aquapark/modules/login/login_model.dart';
import 'package:aquapark/core/di/locator.dart';
import 'package:aquapark/modules/login/login_service.dart';
import 'package:aquapark/modules/menu/menu_page.dart';
import 'package:aquapark/core/widgets/global_dialog.dart';
import 'package:aquapark/core/storage/credential_storage_service.dart';

class LoginPage extends StatefulWidget {
  final bool openedAfterLogout;

  const LoginPage({
    super.key,
    this.openedAfterLogout = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _idController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  final LoginService _loginService = getIt<LoginService>();

  final CredentialStorageService _credentialStorage =
  getIt<CredentialStorageService>();


  final BehaviorSubject<bool> _loading =
  BehaviorSubject<bool>.seeded(false);

  final BehaviorSubject<bool> _obscure =
  BehaviorSubject<bool>.seeded(true);
  @override
  void initState() {
    super.initState();
    Future<void> _loadSavedCredentials() async {
      final tenant = await _credentialStorage.readTenant();
      final username = await _credentialStorage.readUsername();
      final password = await _credentialStorage.readPassword();

      if (!mounted) return;

      _idController.text = tenant ?? '';
      _usernameController.text = username ?? '';
      _passwordController.text = password ?? '';
    }

    _idController = TextEditingController();

    _usernameController = TextEditingController();

    _passwordController = TextEditingController();

    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    _loading.close();
    _obscure.close();

    super.dispose();
  }

  Future<void> _login() async {
    if (_loading.value) {
      return;
    }

    _loading.add(true);

    final result = await _loginService.login(
      tenant: _idController.text.trim(),
      usercode: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    _loading.add(false);

    if (result.success == true &&
        result.apiUrl != null &&
        result.loginModel != null) {
      final model = result.loginModel!;

      if (model.hotelId == 0) {
        model.hotelId =
            int.tryParse(_idController.text.trim()) ?? 0;
      }

      currentUser = model;
      apiUrl = result.apiUrl!;

      await _credentialStorage.saveCredentials(
        tenant: _idController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MenuPage(),
        ),
      );

      return;
    }

    final message = result.message?.trim();

    _showErrorDialog(
      message == null || message.isEmpty
          ? 'login.failed'.tr()
          : message,
    );
  }

  void _showErrorDialog(String message) {

    showDialogBanner(
      DialogType.error,
      message,
      context,
    );
  }


  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool numberOnly = false,
    BehaviorSubject<bool>? obscureSubject,
  }) {
    return LoginTextField(
      controller: controller,
      label: label,
      icon: icon,
      numberOnly: numberOnly,
      obscureSubject: obscureSubject,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/login6.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A)
                          .withValues(alpha: 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: const Color(0xFF0F172A)
                          .withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B8D9)
                            .withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: Color(0xFF00B8D9),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'login.title'.tr(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'login.description'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _field(
                      controller: _idController,
                      label: 'login.tenant_id'.tr(),
                      icon: Icons.business,
                      numberOnly: true,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      controller: _usernameController,
                      label: 'login.username'.tr(),
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),

                    _field(
                      controller: _passwordController,
                      label: 'login.password'.tr(),
                      icon: Icons.lock,
                      obscureSubject: _obscure,
                    ),

                    const SizedBox(height: 26),

                    StreamBuilder<bool>(
                      stream: _loading,
                      initialData: _loading.value,
                      builder: (context, snapshot) {
                        final loading =
                            snapshot.data ?? false;

                        return SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00B8D9),
                                  Color(0xFF008DA5),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius:
                              BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B8D9)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                              loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.transparent,
                                disabledBackgroundColor:
                                Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                disabledForegroundColor:
                                Colors.white,
                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'login.login_button'.tr(),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool numberOnly;
  final BehaviorSubject<bool>? obscureSubject;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.numberOnly = false,
    this.obscureSubject,
  });

  @override
  State<LoginTextField> createState() =>
      _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  final FocusNode _focusNode = FocusNode();

  final BehaviorSubject<bool> _isFocused =
  BehaviorSubject<bool>.seeded(false);

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    _isFocused.add(_focusNode.hasFocus);
  }





@override
void dispose() {
  _focusNode.removeListener(_handleFocusChange);
  _focusNode.dispose();
  _isFocused.close();

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    Widget buildField(bool hidden, bool isFocused) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? const Color(0xFF00B8D9)
                : const Color(0xFFE2E8F0),
            width: isFocused ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  widget.icon,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: hidden,
                    keyboardType: widget.numberOnly
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: widget.numberOnly
                        ? [
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ]
                        : null,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                if (widget.obscureSubject != null) ...[
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      widget.obscureSubject!.add(!hidden);
                    },
                    child: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: _isFocused,
      initialData: _isFocused.value,
      builder: (context, focusSnapshot) {
        final isFocused = focusSnapshot.data ?? false;

        if (widget.obscureSubject == null) {
          return buildField(false, isFocused);
        }

        return StreamBuilder<bool>(
          stream: widget.obscureSubject,
          initialData: widget.obscureSubject!.value,
          builder: (context, obscureSnapshot) {
            final hidden = obscureSnapshot.data ?? true;

            return buildField(hidden, isFocused);
          },
        );
      },
    );
  }
}