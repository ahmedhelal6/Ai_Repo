import 'package:ai_fitness_coach/controllers/home_controller.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/models/workout_model.dart';
import 'package:ai_fitness_coach/models/workout_progress_model.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:ai_fitness_coach/views/aicoachscreen.dart';
import 'package:ai_fitness_coach/views/chat_screen.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/views/profile_screen.dart';
import 'package:ai_fitness_coach/views/saved_workout_details_screen.dart';
import 'package:ai_fitness_coach/views/workout_screen.dart';
import 'package:ai_fitness_coach/widgets/diet_section.dart';
import 'package:ai_fitness_coach/widgets/home_bottom_nav.dart';
import 'package:ai_fitness_coach/widgets/progress_overview_section.dart';
import 'package:ai_fitness_coach/widgets/saved_workouts_section.dart';
import 'package:ai_fitness_coach/widgets/welcome_container.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = HomeController();

  AuthService get _authService => controller.authService;

  int _selectedIndex = 0;

  List<WorkoutModel> _savedWorkouts = [];
  WorkoutProgressModel? _progress;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkTokenThenLoadData();
  }

  Future<void> _checkTokenThenLoadData() async {
    final refreshToken = await _authService.getRefreshToken();

    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await _goToLogin();
      return;
    }

    await _loadData();
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

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final (workouts, progress) = await controller.loadData();

      if (!mounted) return;

      setState(() {
        _savedWorkouts = workouts;
        _progress = progress;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      final message = controller.getErrorMessage(error);

      if (_isUnauthorizedMessage(message)) {
        await _goToLogin();
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });

      _showSnackBar(message);
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    try {
      await controller.deleteWorkout(workoutId);
      await _loadData();

      _showSnackBar('Workout deleted successfully');
    } catch (error) {
      if (!mounted) return;

      final message = controller.getErrorMessage(error);

      if (_isUnauthorizedMessage(message)) {
        await _goToLogin();
        return;
      }

      _showSnackBar(message);
    }
  }

  Future<void> _navigateTo(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Home
      return;
    } else if (index == 1) {
      // Workout
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WorkoutScreen(),
        ),
      );

      if (result == true) {
        await _checkTokenThenLoadData();
      }
    } else if (index == 2) {
      // AI Coach
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AiCoachScreen(),
        ),
      );
    } else if (index == 3) {
      // Chat
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        ),
      );
    } else if (index == 4) {
      // Profile
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(userData: widget.userData),
        ),
      );

      await _checkTokenThenLoadData();
    }

    if (!mounted) return;

    setState(() {
      _selectedIndex = 0;
    });
  }

  void _openWorkoutDetails(WorkoutModel workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedWorkoutDetailsScreen(workout: workout),
      ),
    ).then((_) {
      _checkTokenThenLoadData();
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: .06),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _checkTokenThenLoadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Column(
      children: [
        SavedWorkoutsSection(
          workouts: _savedWorkouts,
          onOpenWorkout: _openWorkoutDetails,
          onDeleteWorkout: _deleteWorkout,
        ),
        const SizedBox(height: 18),
        const DietSection(),
        const SizedBox(height: 18),
        if (_progress != null) ProgressOverviewSection(progress: _progress!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _checkTokenThenLoadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              WelcomeContainer(
                userData: widget.userData,
                onStartWorkout: () => _navigateTo(1),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 18),
              _buildHomeContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: HomeBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _navigateTo,
        ),
      ),
    );
  }
}