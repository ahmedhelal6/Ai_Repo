import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/services/notification_service.dart';
import 'package:ai_fitness_coach/views/home_screen.dart';
import 'package:ai_fitness_coach/views/onboarding_screen.dart';
import 'package:ai_fitness_coach/services/auth_service.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  late final Future<_StartupResult> startupFuture;

  @override
  void initState() {
    super.initState();
    startupFuture = loadStartupState();
  }

  Future<_StartupResult> loadStartupState() async {
    try {
      final authService = AuthService();

      final bool isLoggedIn = await authService.isLoggedIn();
      final UserData? userData = await UserData.load();

      return _StartupResult(
        isLoggedIn: isLoggedIn,
        userData: userData,
      );
    } catch (e) {
      debugPrint('Startup error: $e');

      return const _StartupResult(
        isLoggedIn: false,
        userData: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fitness Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        useMaterial3: true,
      ),
      home: FutureBuilder<_StartupResult>(
        future: startupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          final result = snapshot.data;

          if (result != null && result.isLoggedIn && result.userData != null) {
            return HomeScreen(userData: result.userData!);
          }

          return OnboardingScreen();
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF080808),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupResult {
  final bool isLoggedIn;
  final UserData? userData;

  const _StartupResult({
    required this.isLoggedIn,
    required this.userData,
  });
}