import 'package:ai_fitness_coach/controllers/profile_controller.dart';
import 'package:ai_fitness_coach/core/errors/failure.dart';
import 'package:ai_fitness_coach/core/theme/profile_theme.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/widgets/profile_header_section.dart';
import 'package:ai_fitness_coach/widgets/profile_settings_section.dart';
import 'package:ai_fitness_coach/widgets/profile_stats_section.dart';
import 'package:ai_fitness_coach/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final ProfileController controller = ProfileController();

  AuthService get _authService => controller.authService;

  late UserData userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    userData = widget.userData;
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  bool _isUnauthorizedMessage(String message) {
    final lowerMessage = message.toLowerCase();

    return lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('401') ||
        lowerMessage.contains('session expired') ||
        lowerMessage.contains('invalid or expired refresh token');
  }

  Future<void> _goToLogin() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }


  Future<void> _loadProfile() async {
    _setLoading(true);

    try {
      final updatedUser = await controller.loadProfile(userData);

      if (!mounted) return;

      setState(() {
        userData = updatedUser;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      final message = _getErrorMessage(error);

      if (_isUnauthorizedMessage(message)) {
        await _goToLogin();
        return;
      }

      setState(() {
        errorMessage = message;
      });

      _showMessage(message, isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;

    setState(() {
      isLoading = value;
    });
  }

  String _getErrorMessage(Object error) {
    if (error is Failure) return error.message;

    final message = error.toString().replaceFirst('Exception: ', '').trim();

    return message.isNotEmpty ? message : 'Failed to load profile';
  }

  Future<void> _refreshProfile() async {
    await _loadProfile();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isError
            ? Colors.redAccent.withValues(alpha: .9)
            : Colors.greenAccent.shade700.withValues(alpha: .9),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage ?? 'Failed to load profile',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshProfile,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ProfileTopBar(
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            ProfileHeaderSection(
              userData: userData,
              onChanged: _refreshProfile,
            ),
            const SizedBox(height: 22),
            ProfileStatsSection(userData: userData),
            const SizedBox(height: 18),
            const SectionTitle(title: 'ACCOUNT DETAILS'),
            const SizedBox(height: 10),
            ProfileSettingsSection(
              userData: userData,
              onChanged: _refreshProfile,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : errorMessage != null
                ? _buildErrorView()
                : _buildProfileContent(),
      ),
    );
  }
}