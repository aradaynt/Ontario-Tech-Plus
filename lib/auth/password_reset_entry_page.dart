// Ontario Tech Plus - password_reset_entry_page.dart

// This is a page only accessible after link click in password recovery email

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';

// Page for new password after email recovery
class PasswordResetEntryPage extends ConsumerStatefulWidget {
  const PasswordResetEntryPage({super.key});

  @override
  ConsumerState<PasswordResetEntryPage> createState() =>
      _PasswordResetEntryPageState();
}

class _PasswordResetEntryPageState
    extends ConsumerState<PasswordResetEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;

  static const _fieldFill = Color(0x33FFFFFF);
  static const _fieldBorder = Color(0x55FFFFFF);
  static const _fieldBorderFocus = Color(0xCCFFFFFF);

  // Input decoration helper for the password fields
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      floatingLabelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Color(0xCCFFFFFF)),
      prefixIcon: icon == null ? null : Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorderFocus, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  // Validate the new password input
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'New password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Ensure confirmation password matches
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Submit new password, then return user to login
  Future<void> _submitNewPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .updatePassword(_passwordController.text.trim());
      // Show success message after redirecting back to login pge
      ref
          .read(authStatusMessageProvider.notifier)
          .setMessage('Your password has been reset, please login.');
      await ref.read(authServiceProvider).signOut();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthFailure
            ? error.message
            : 'Password could not be updated. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/backgrounds/LoginBackground.png',
              fit: BoxFit.fill,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 130, 24, 24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      // Padding inside of the password reset card
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0x22000000),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header row with back button and title
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Password Reset',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // New password field
                          TextFormField(
                            controller: _passwordController,
                            decoration: _inputDecoration(
                              'Enter New Password',
                              icon: Icons.lock_outline,
                            ),
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            validator: _validatePassword,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          // Confirm password field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: _inputDecoration(
                              'Confirm New Password',
                              icon: Icons.lock_reset,
                            ),
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            validator: _validateConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_loading) _submitNewPassword();
                            },
                          ),
                          // If there is an error, place to show
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFFFB4B4)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Submit button for the new password
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submitNewPassword,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
