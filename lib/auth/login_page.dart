// Ontario Tech Plus - login_page.dart

// This is a basic login page which allows Login and Account Creation

// WIP: Still needs a proper UI look and feel

import 'package:flutter/material.dart';
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
      if (_isLogin) {
        await auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
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
    } catch (e) {
      setState(() {
        _error = "Authentication failed. Please try again.";
        //_error = e.toString();
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
    return Scaffold(
      appBar: AppBar(
        // Toggle between login or signup
        title: Text(
          _isLogin ? "Ontario Tech Plus Login" : "Ontario Tech Plus Signup",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Form
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_loading) _submit();
                  },
                ),

                // Signup Fields shown
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                    validator: (v) => _validateRequired(v, "First name"),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                    validator: (v) => _validateRequired(v, "Last name"),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _studentNumberController,
                    decoration: const InputDecoration(
                      labelText: "Student Number",
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateStudentNumber,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _programController,
                    decoration: const InputDecoration(labelText: "Program"),
                    validator: (v) => _validateRequired(v, "Program"),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedFaculty,
                    decoration: const InputDecoration(labelText: "Faculty"),
                    items: _faculties
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedFaculty = val),
                    validator: (v) => v == null ? "Faculty is required" : null,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(labelText: "Year"),
                    items: _years
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text("Year $y"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedYear = val),
                    validator: (v) => v == null ? "Year is required" : null,
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),

                // If there is an error, place to show
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),

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
                        : Text(_isLogin ? "Login" : "Sign Up"),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
