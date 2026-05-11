import 'package:ai_fitness_coach/controllers/auth_controller.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/views/verify_email_screen.dart';
import 'package:ai_fitness_coach/widgets/app_textfield_widget.dart';
import 'package:ai_fitness_coach/widgets/auth_button.dart';
import 'package:ai_fitness_coach/widgets/auth_footer_text.dart';
import 'package:ai_fitness_coach/widgets/auth_header.dart';
import 'package:ai_fitness_coach/widgets/password_field_widget.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController controller = AuthController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      final updatedUser = await controller.register(
        userData: widget.userData,
        username: username,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Account created. Check your email for the OTP code.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            userData: updatedUser,
            email: email,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(_getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isNotEmpty && message != 'null') {
      return message;
    }

    return 'Something went wrong';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter username';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter email';
    }

    if (!value.contains('@')) {
      return 'Invalid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm your password';
    }

    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _goToLogin() {
    if (_isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthHeaderWidget(title: 'Create Account'),
                AppTextField(
                  hint: 'Username',
                  controller: _usernameController,
                  validator: _validateUsername,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  hint: 'Email',
                  controller: _emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                PasswordFieldWidget(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                PasswordFieldWidget(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 30),
                AuthButtonWidget(
                  text: 'CREATE ACCOUNT',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _createAccount,
                ),
                const SizedBox(height: 20),
                AuthFooterWidget(
                  questionText: 'Already have an account?',
                  actionText: 'Login',
                  onPressed: _goToLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}