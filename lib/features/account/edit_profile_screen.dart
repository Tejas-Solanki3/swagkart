// =============================================================================
// File: lib/features/account/edit_profile_screen.dart
// Purpose: Profile editing screen allowing users to update full name, contact
//          phone number, and residential delivery address with form validation.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/nav.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swag_button.dart';
import '../../core/widgets/swag_icon.dart';
import '../../core/widgets/swag_logo.dart';
import '../../state/app_store.dart';

/// Form screen for editing shopper personal details and shipping address.
///
/// Updates [SwagAppStore.currentUser] and persists the changes to Cloud Firestore.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}


class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _stateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<SwagAppStore>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _streetController = TextEditingController(text: user?.street ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _pincodeController = TextEditingController(text: user?.pincode ?? '');
    _stateController = TextEditingController(text: user?.state ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await context.read<SwagAppStore>().updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        state: _stateController.text.trim(),
      );

      if (mounted) {
        SwagNav.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SwagColors.ink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              'Profile updated successfully in Firestore! ✨',
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
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SwagAppStore>().currentUser;

    return Scaffold(
      backgroundColor: SwagColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 88,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SwagLogo(size: 26, showText: false),
            ],
          ),
        ),
        title: Text('Edit Profile', style: SwagTheme.display(size: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              // Avatar preview
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            SwagColors.accentSoft,
                            SwagColors.butterSoft,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: SwagColors.surface, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: SwagColors.line,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'SK',
                          style: SwagTheme.display(
                            size: 28,
                            color: SwagColors.accentDeep,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: SwagColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const SwagIcon(
                          'sparkles',
                          size: 14,
                          color: SwagColors.canvas,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: SwagTheme.cardDecoration(radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      style: SwagTheme.display(size: 17),
                    ),
                    const SizedBox(height: 16),
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
                      decoration: _fieldDeco(hint: 'Your name', icon: 'user'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Phone Number',
                      style: SwagTheme.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDeco(
                        hint: '+91 98765 43210',
                        icon: 'phone',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shipping Address Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: SwagTheme.cardDecoration(radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: SwagTheme.display(size: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Used for 1-tap checkout on all streetwear drops',
                      style: SwagTheme.body(
                        size: 12,
                        color: SwagColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Street / Flat / Colony',
                      style: SwagTheme.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _streetController,
                      decoration: _fieldDeco(
                        hint: 'Flat 402, High Street Phoenix',
                        icon: 'location',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'City',
                                style: SwagTheme.body(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cityController,
                                decoration: _fieldDeco(
                                  hint: 'Mumbai',
                                  icon: 'location',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PIN Code',
                                style: SwagTheme.body(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                decoration: _fieldDeco(
                                  hint: '400013',
                                  icon: 'tag',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'State',
                      style: SwagTheme.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stateController,
                      decoration: _fieldDeco(
                        hint: 'Maharashtra',
                        icon: 'location',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save CTA
              SwagButton(
                label: _isSaving ? 'Saving Changes...' : 'Save Profile',
                icon: 'sparkles',
                height: 52,
                onTap: _isSaving ? () {} : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDeco({required String hint, required String icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: SwagTheme.body(size: 13, color: SwagColors.inkFaint),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: SwagIcon(icon, size: 18, color: SwagColors.inkSoft),
      ),
      filled: true,
      fillColor: SwagColors.canvas,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SwagColors.accent, width: 1.5),
      ),
    );
  }
}
