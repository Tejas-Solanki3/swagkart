// =============================================================================
// File: lib/features/auth/login_screen.dart
// Purpose: Authentication view supporting email/password sign-in, new account
//          registration with address fields, demo one-tap logins, and password reset.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../services/auth_service.dart';
import '../../state/app_store.dart';

/// Screen handling user sign in, registration, and demo credentials.
///
/// Features:
/// - Tab switch between Login and Sign Up
/// - Form validation for email, password, name, and address
/// - One-tap quick login for Demo Shopper and Demo Admin
/// - Password visibility toggle and error display
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialIsSignUp = false});


  final bool initialIsSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isSignUp = widget.initialIsSignUp;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final store = context.read<SwagAppStore>();
    try {
      if (_isSignUp) {
        final email = _emailController.text.trim().toLowerCase();
        if (email.contains('admin')) {
          throw 'Admin accounts cannot be created from the sign-up form. Please sign in with your administrator credentials.';
        }
        await store.register(
          name: _nameController.text.trim(),
          email: email,
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'customer',
        );
      } else {
        await store.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      if (mounted) {
        if (Navigator.canPop(context)) {
          SwagNav.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SwagColors.ink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              _isSignUp
                  ? 'Welcome to SwagKart, ${_nameController.text.trim()}! 🛍️'
                  : 'Welcome back! You’re signed in.',
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w600,
                color: SwagColors.canvas,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _demoLogin(bool isAdmin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final store = context.read<SwagAppStore>();
    try {
      if (isAdmin) {
        await store.signInDemoAdmin();
      } else {
        await store.signInDemoCustomer();
      }
      if (mounted) {
        if (Navigator.canPop(context)) {
          SwagNav.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SwagColors.ink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              isAdmin
                  ? 'Logged in as Demo Admin 👑'
                  : 'Logged in as Demo Shopper 🎒',
              style: SwagTheme.body(
                size: 13,
                weight: FontWeight.w600,
                color: SwagColors.canvas,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: SwagColors.surface,
        title: Text('Reset Password', style: SwagTheme.display(size: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we will send you a password reset link.',
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'name@swagkart.in',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: SwagIcon('mail', size: 18, color: SwagColors.inkFaint),
                ),
                filled: true,
                fillColor: SwagColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SwagColors.ink,
              foregroundColor: SwagColors.canvas,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                await AuthService.instance.sendPasswordReset(emailCtrl.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset email sent to ${emailCtrl.text}!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: Text(
              'Send Link',
              style: SwagTheme.body(size: 13, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwagColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: Navigator.canPop(context) ? 88 : 46,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Navigator.canPop(context)) ...[
                Pressable(
                  onTap: () => SwagNav.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: SwagColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SwagColors.line,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SwagIcon(
                        'arrow-left',
                        size: 16,
                        color: SwagColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const SwagLogo(size: 26, showText: false),
            ],
          ),
        ),
        title: Text(
          _isSignUp ? 'Join SwagKart' : 'Welcome Back',
          style: SwagTheme.display(size: 19),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                children: [
                  // Logo Hero
                  Center(
                    child:
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: SwagColors.ink.withValues(alpha: 0.16),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ).animate().scale(
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      _isSignUp
                          ? 'Create your Swag profile'
                          : 'Sign in to your account',
                      style: SwagTheme.display(size: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _isSignUp
                          ? 'Track drops, save streetwear and unlock member perks'
                          : 'Orders, saved bag and VIP drops waiting for you',
                      textAlign: TextAlign.center,
                      style: SwagTheme.body(
                        size: 13,
                        color: SwagColors.inkSoft,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tab switcher (Sign In vs Join Club)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SwagColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SwagColors.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: !_isSignUp
                                    ? SwagColors.ink
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: SwagTheme.body(
                                    size: 13.5,
                                    weight: FontWeight.w700,
                                    color: !_isSignUp
                                        ? SwagColors.canvas
                                        : SwagColors.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            }),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: _isSignUp
                                    ? SwagColors.ink
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  'Join the Club',
                                  style: SwagTheme.body(
                                    size: 13.5,
                                    weight: FontWeight.w700,
                                    color: _isSignUp
                                        ? SwagColors.canvas
                                        : SwagColors.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error banner
                  if (_errorMessage != null) ...[
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: SwagColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: SwagColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SwagIcon(
                                'alert',
                                size: 18,
                                color: SwagColors.accentDeep,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: SwagTheme.body(
                                    size: 12.5,
                                    weight: FontWeight.w600,
                                    color: SwagColors.accentDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .shake(duration: 350.ms),
                    const SizedBox(height: 16),
                  ],

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: SwagTheme.cardDecoration(radius: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSignUp) ...[
                          Text(
                            'Full Name',
                            style: SwagTheme.body(
                              size: 12.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'e.g. Tejas Solanki',
                              icon: 'user',
                            ),
                            validator: (v) {
                              if (_isSignUp &&
                                  (v == null || v.trim().isEmpty)) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        Text(
                          'Email Address',
                          style: SwagTheme.body(
                            size: 12.5,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hint: 'yourname@example.com',
                            icon: 'mail',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (_isSignUp) ...[
                          Text(
                            'Mobile Number (Optional)',
                            style: SwagTheme.body(
                              size: 12.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              hint: '+91 98765 43210',
                              icon: 'phone',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: SwagTheme.body(
                                size: 12.5,
                                weight: FontWeight.w700,
                              ),
                            ),
                            if (!_isSignUp)
                              Pressable(
                                onTap: _forgotPasswordDialog,
                                child: Text(
                                  'Forgot?',
                                  style: SwagTheme.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: SwagColors.accentDeep,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: 'lock',
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: SwagColors.inkFaint,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a password';
                            }
                            if (_isSignUp && v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),

                        // Action Button
                        SwagButton(
                          label: _isLoading
                              ? 'Connecting...'
                              : (_isSignUp ? 'Create Account' : 'Sign In'),
                          icon: _isSignUp ? 'sparkles' : 'arrow-right',
                          height: 52,
                          onTap: _isLoading ? () {} : _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo quick access
                  Center(
                    child: Text(
                      'OR TEST WITH DEMO ACCOUNTS',
                      style: SwagTheme.body(
                        size: 11,
                        weight: FontWeight.w800,
                        color: SwagColors.inkFaint,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: SwagColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: SwagColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _demoLogin(false),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SwagIcon(
                                'user',
                                size: 16,
                                color: SwagColors.accentDeep,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Demo Shopper',
                                style: SwagTheme.body(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                  color: SwagColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: SwagColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: SwagColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _isLoading ? null : () => _demoLogin(true),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SwagIcon(
                                'lock',
                                size: 16,
                                color: SwagColors.lavenderDeep,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Demo Admin',
                                style: SwagTheme.body(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                  color: SwagColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required String icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: SwagTheme.body(size: 13, color: SwagColors.inkFaint),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: SwagIcon(icon, size: 18, color: SwagColors.inkSoft),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: SwagColors.canvas,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: SwagColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: SwagColors.accentDeep),
      ),
    );
  }
}
