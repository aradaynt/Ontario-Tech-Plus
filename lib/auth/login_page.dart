// Ontario Tech Plus - login_page.dart

// This is a basic login page which allows Login and Account Creation

// UI can still use some work

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _programController = TextEditingController();
  final _studentNumberFocusNode = FocusNode();

  String? _selectedFaculty;
  String? _selectedYear;

  final List<String> _faculties = [
    "Science",
    "Engineering",
    "Business",
    "Health Sciences",
    "Education",
    "Social Science & Humanities",
  ];

  final List<String> _years = ["1", "2", "3", "4", "5+"];

  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  // Signup step tracking
  // 0 = email, password, firstname, lastname, student number
  // 1 = program, faculty, year
  int _signupStep = 0;

  // ====================== UI Helpers ======================

  static const _fieldFill = Color(0x33FFFFFF);
  static const _fieldBorder = Color(0x55FFFFFF);
  static const _fieldBorderFocus = Color(0xCCFFFFFF);

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

  // ====================== Submittion Function (Login/Signup) ======================
  Future<void> _submit() async {
    // Only validate the the currently shown fields
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = ref.read(authServiceProvider); //Reference the auth service

    // Only use certain fields depending on mode (signup/signin)
    try {
      // Base login
      if (_isLogin) {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Handles signups
      } else {
        // step 1 simply proceeds to step two with no signup
        if (_signupStep == 0) {
          setState(() {
            _signupStep = 1;
          });
        } else {
          // Step 2 is where hte user actually signs up
          await auth.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _studentNumberController.text.trim(),
            _programController.text.trim(),
            _selectedFaculty!,
            _selectedYear!,
          );
        }
      }
    } catch (e) {
      // Handles errors on login
      setState(() {
        _error = e is AuthFailure
            ? e.message
            : "Authentication failed. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _toggleMode() {
    // Clear the forms validation
    _formKey.currentState?.reset();

    // Can use later if want to clear the fields when switchign to signup and vice versa.
    // _emailController.clear();
    // _passwordController.clear();

    setState(() {
      _isLogin = !_isLogin;
      _error = null;

      // Reset step when changing modes
      _signupStep = 0;

      // reset the drop downs when changing modes
      _selectedFaculty = null;
      _selectedYear = null;
    });
  }

  // Handles clearing the validation when going back
  void _backSignupStep() {
    // Clear the forms validation
    _formKey.currentState?.reset();

    setState(() {
      _signupStep = 0;
      _error = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    _programController.dispose();
    _studentNumberFocusNode.dispose();
    super.dispose();
  }

  // ====================== Validation Helpers ======================

  // Validate the email input (Must be proper email format)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  // Validate the password input (Must have 6 characters or more)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  // Ensure all requred fields are filled
  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return "$field is required";
    }
    return null;
  }

  // Ensure only numbers entered for student number
  String? _validateStudentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Student number is required";
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "Student number must contain digits only";
    }
    return null;
  }

  // ====================== Page Building ======================
  @override
  Widget build(BuildContext context) {
    // Button text should change depending on login/signup step
    final buttonText = _isLogin
        ? "Login"
        : (_signupStep == 0 ? "Next" : "Sign Up");

    return Scaffold(
      appBar: AppBar(
        // Toggle between login or signup
        backgroundColor: Colors.transparent,
        elevation: 0,
        // title: Text(
        //   _isLogin ? "Ontario Tech Plus Login" : "Ontario Tech Plus Signup",
        // ),
      ),
      extendBodyBehindAppBar: true,

      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              "assets/backgrounds/LoginBackground.png",
              fit: BoxFit.fill, // Compress/Stretch to fit screen
            ),
            SafeArea(
              child: Padding(
                // Padding/placement on screen for the login/signup card
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      // Padding inside of the login card
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0x22000000),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),

                      // Column for the login card
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ), //Space from top of card before first field
                          // Login Form (will hide on step 2 of signup)
                          if (_isLogin || (!_isLogin && _signupStep == 0)) ...[
                            // Email input
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration(
                                "Email",
                                icon: Icons.email,
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              textInputAction: TextInputAction.next,
                            ),

                            const SizedBox(height: 16),

                            // Password input
                            TextFormField(
                              controller: _passwordController,
                              decoration: _inputDecoration(
                                "Password",
                                icon: Icons.lock_outline,
                              ),
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              validator: _validatePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_loading) _submit();
                              },
                            ),
                          ],

                          // Signup Fields shown on toggle
                          if (!_isLogin) ...[
                            // Step 1: email/password already shown, now show
                            // firstname, lastname, student number
                            if (_signupStep == 0) ...[
                              const SizedBox(height: 16),

                              // First name field
                              TextFormField(
                                controller: _firstNameController,
                                decoration: _inputDecoration(
                                  "First Name",
                                  icon: Icons.person_outline,
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (v) =>
                                    _validateRequired(v, "First name"),
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 16),

                              // Last name input field
                              TextFormField(
                                controller: _lastNameController,
                                decoration: _inputDecoration(
                                  "Last Name",
                                  icon: Icons.person_outline,
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (v) =>
                                    _validateRequired(v, "Last name"),
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 16),

                              // Student number input field
                              ListenableBuilder(
                                listenable: Listenable.merge([
                                  _studentNumberController,
                                  _studentNumberFocusNode,
                                ]),
                                builder: (context, _) {
                                  final showCount =
                                      _studentNumberFocusNode.hasFocus;

                                  return TextFormField(
                                    controller: _studentNumberController,
                                    focusNode: _studentNumberFocusNode,
                                    decoration:
                                        _inputDecoration(
                                          "Student Number",
                                          icon: Icons.badge_outlined,
                                        ).copyWith(
                                          counterText: '',
                                          // Counter for the student number entry
                                          suffixText: showCount
                                              ? '${_studentNumberController.text.length}/9'
                                              : null,
                                          suffixStyle: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                    style: const TextStyle(color: Colors.white),
                                    // Set keyboard type, and the max length
                                    keyboardType: TextInputType.number,
                                    maxLength: 9,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                                    validator: _validateStudentNumber,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (!_loading) _submit(); // "Next"
                                    },
                                  );
                                },
                              ),
                            ],

                            // AFter user hits the next button, go to step 2
                            // Step 2: program, faculty, year
                            if (_signupStep == 1) ...[
                              // Back button so user can return to step 1
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _loading ? null : _backSignupStep,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Back",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                              // Program input field
                              TextFormField(
                                controller: _programController,
                                decoration: _inputDecoration(
                                  "Program",
                                  icon: Icons.menu_book_outlined,
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (v) =>
                                    _validateRequired(v, "Program"),
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 16),

                              // Faculty drop down selection
                              DropdownButtonFormField<String>(
                                initialValue: _selectedFaculty,
                                decoration: _inputDecoration(
                                  "Faculty",
                                  icon: Icons.school_outlined,
                                ),
                                dropdownColor: const Color(0xFF0B2C66),
                                style: const TextStyle(color: Colors.white),
                                items: _faculties
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedFaculty = val),
                                validator: (v) =>
                                    v == null ? "Faculty is required" : null,
                              ),

                              const SizedBox(height: 16),

                              // Year section drop down
                              DropdownButtonFormField<String>(
                                initialValue: _selectedYear,
                                decoration: _inputDecoration(
                                  "Year",
                                  icon: Icons.calendar_today_outlined,
                                ),
                                dropdownColor: const Color(0xFF0B2C66),
                                style: const TextStyle(color: Colors.white),
                                items: _years
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text("Year $y"),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedYear = val),
                                validator: (v) =>
                                    v == null ? "Year is required" : null,
                              ),
                            ],
                          ],

                          const SizedBox(height: 24),

                          // If there is an error, place to show
                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFFFB4B4)),
                            ),

                          const SizedBox(height: 12),

                          // Login/Signup Submt Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(buttonText),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Toggle button for signup or signin
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Sign up"
                                  : "Already have an account? Login",
                              style: const TextStyle(color: Colors.white),
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
