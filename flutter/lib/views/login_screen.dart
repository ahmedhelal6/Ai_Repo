import 'package:ai_fitness_coach/controllers/auth_controller.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/views/forgot_password_screen.dart';
import 'package:ai_fitness_coach/views/home_screen.dart';
import 'package:ai_fitness_coach/widgets/app_textfield_widget.dart';
import 'package:ai_fitness_coach/widgets/auth_button.dart';
import 'package:ai_fitness_coach/widgets/auth_header.dart';
import 'package:ai_fitness_coach/widgets/password_field_widget.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController controller = AuthController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_validateInputs(email, password)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await controller.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userData: user),
        ),
        (route) => false,
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

  bool _validateInputs(String email, String password) {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (email.isEmpty) {
      _emailError = 'Enter email';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Invalid email';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Enter password';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    setState(() {});

    return isValid;
  }

  String _getErrorMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isNotEmpty && message != 'null') {
      return message;
    }

    return 'Something went wrong after login.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeaderWidget(title: 'Login'),
                AppTextField(
                  hint: 'Email',
                  controller: _emailController,
                ),
                _buildErrorText(_emailError),
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
                ),
                _buildErrorText(_passwordError),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AuthButtonWidget(
                  text: 'LOGIN',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}