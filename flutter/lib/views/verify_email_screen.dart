import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/views/home_screen.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/widgets/app_textfield_widget.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.userData,
    required this.email,
  });

  final UserData userData;
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyEmail(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      final token = await _authService.getAccessToken();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      final updatedUser = widget.userData.copyWith(
        email: widget.email,
      );

      await updatedUser.save();

      if (!mounted) return;

      _showMessage('Email verified successfully');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userData: updatedUser),
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

  void _goToLogin() {
    if (_isLoading) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter verification code';
    }

    return null;
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Verify Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter the code sent to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'OTP Code',
                  controller: _codeController,
                  validator: _validateCode,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            'VERIFY EMAIL',
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading ? null : _goToLogin,
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}