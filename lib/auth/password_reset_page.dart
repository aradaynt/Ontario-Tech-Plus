// Ontario Tech Plus - password_reset_page.dart

// This page is what allows the user to enter an active account email to reset their password.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';

// Page for requesting a password reset email
class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successMessage;
  String? _submittedEmail;

  static const _fieldFill = Color(0x33FFFFFF);
  static const _fieldBorder = Color(0x55FFFFFF);
  static const _fieldBorderFocus = Color(0xCCFFFFFF);

  // Input decoration helper for the email field
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
    );
  }

  // Validate the email input
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Reset page back to the initial email entry state
  void _resetFormState() {
    _formKey.currentState?.reset();
    _emailController.clear();
    setState(() {
      _error = null;
      _successMessage = null;
      _submittedEmail = null;
    });
  }

  // Request a password reset email from Supabase
  Future<void> _requestPasswordReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      await ref.read(authServiceProvider).resetPassword(email);

      if (!mounted) return;
      setState(() {
        _submittedEmail = email;
        _successMessage =
            'If an account exists for that email, a password reset link has been sent.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthFailure
            ? error.message
            : 'Password reset could not be requested. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Dispose of contrls to prevent memory leaks
  @override
  void dispose() {
    _emailController.dispose();
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
                          // Email entry
                          if (_submittedEmail == null)
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration(
                                'Email',
                                icon: Icons.email,
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_loading) _requestPasswordReset();
                              },
                            ),
                          // After a request, show which email was used
                          if (_submittedEmail != null)
                            Column(
                              children: [
                                Text(
                                  'Request made for: $_submittedEmail',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                              ],
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
                          // Success message after requesting reset email
                          if (_successMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _successMessage!,
                              style: const TextStyle(color: Color(0xFFB7F7C3)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Main button for sending or resending the reset email
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : _requestPasswordReset,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _submittedEmail == null
                                          ? 'Request Password Reset'
                                          : 'Resend Email',
                                    ),
                            ),
                          ),
                          if (_submittedEmail != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              // second button to reset the page fo new email
                              child: OutlinedButton(
                                onPressed: _loading ? null : _resetFormState,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(
                                    color: Color(0x66FFFFFF),
                                  ),
                                  backgroundColor: const Color(0x14FFFFFF),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text('Try Different Email'),
                              ),
                            ),
                          ],
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
