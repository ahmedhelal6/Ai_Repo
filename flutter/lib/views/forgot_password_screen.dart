import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/widgets/app_textfield_widget.dart';
import 'package:ai_fitness_coach/widgets/auth_button.dart';
import 'package:ai_fitness_coach/widgets/auth_header.dart';
import 'package:ai_fitness_coach/widgets/password_field_widget.dart';
import 'package:ai_fitness_coach/widgets/step_indicator_widget.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSending = false;
  bool _isResetting = false;
  bool _codeSent = false;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _otpError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();

    if (!_validateEmail(email)) return;

    setState(() {
      _isSending = true;
    });

    final wasCodeSentBefore = _codeSent;

    try {
      if (_codeSent) {
        await _authService.resendOtp(email: email);
      } else {
        await _authService.forgotPassword(email: email);
      }

      if (!mounted) return;

      setState(() {
        _codeSent = true;
        _otpController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _otpError = null;
        _newPasswordError = null;
        _confirmPasswordError = null;
      });

      _showSnackBar(
        wasCodeSentBefore
            ? 'A new verification code has been sent'
            : 'A verification code has been sent',
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_validateResetData(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    )) {
      return;
    }

    setState(() {
      _isResetting = true;
    });

    try {
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (!mounted) return;

      _showSnackBar('Password reset successfully');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  bool _validateEmail(String email) {
    setState(() {
      _emailError = null;
    });

    bool isValid = true;

    if (email.isEmpty) {
      _emailError = 'Enter email';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Invalid email';
      isValid = false;
    }

    setState(() {});

    return isValid;
  }

  bool _validateResetData({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    setState(() {
      _emailError = null;
      _otpError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    if (email.isEmpty) {
      _emailError = 'Enter email';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Invalid email';
      isValid = false;
    }

    if (otp.isEmpty) {
      _otpError = 'Enter OTP';
      isValid = false;
    }

    if (newPassword.isEmpty) {
      _newPasswordError = 'Enter new password';
      isValid = false;
    } else if (newPassword.length < 6) {
      _newPasswordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm your password';
      isValid = false;
    } else if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
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

    return 'Something went wrong';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

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

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _codeSent ? 'Step 2: Reset password' : 'Step 1: Verify your email',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _codeSent
                ? 'Enter the OTP sent to your email and choose a new password.'
                : 'We will send a verification code to your email address.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          StepIndicatorWidget(isSecondStepActive: _codeSent),
          const SizedBox(height: 24),
          AppTextField(
            hint: 'Email address',
            controller: _emailController,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.white70,
            ),
          ),
          _buildErrorText(_emailError),
          const SizedBox(height: 18),
          AuthButtonWidget(
            text: _codeSent ? 'Resend Code' : 'Send Code',
            isLoading: _isSending,
            onPressed: _isSending ? null : _sendResetCode,
            height: 56,
          ),
          if (_codeSent) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 24),
            AppTextField(
              hint: 'OTP code',
              controller: _otpController,
              prefixIcon: const Icon(
                Icons.verified_outlined,
                color: Colors.white70,
              ),
            ),
            _buildErrorText(_otpError),
            const SizedBox(height: 16),
            PasswordFieldWidget(
              hint: 'New password',
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.white70,
              ),
            ),
            _buildErrorText(_newPasswordError),
            const SizedBox(height: 16),
            PasswordFieldWidget(
              hint: 'Confirm new password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.white70,
              ),
            ),
            _buildErrorText(_confirmPasswordError),
            const SizedBox(height: 22),
            AuthButtonWidget(
              text: 'Reset Password',
              isLoading: _isResetting,
              onPressed: _isResetting ? null : _resetPassword,
              backgroundColor: const Color(0xFF2A2A2E),
              foregroundColor: Colors.white,
              height: 56,
            ),
          ],
        ],
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
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const AuthHeaderWidget(
                title: 'Forgot Password?',
                subtitle:
                    'Enter your email to receive a verification code\nand reset your password securely.',
                icon: Icons.lock_reset_rounded,
              ),
              _buildMainCard(),
            ],
          ),
        ),
      ),
    );
  }
}