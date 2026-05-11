
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:ai_fitness_coach/widgets/blur_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/selected_gender_screen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});
  final UserData userData = UserData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/0fc6ebb62874bf5b6305e7cc5746bd05.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.black87],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 4),

                  BlurWidget(
                    child: Column(
                      children: const [
                        Text(
                          'Train Smarter.',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Get stronger with AI powered workouts',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  Column(
                    children: [
                      CustomButton(
                        text: 'GET STARTED',
                        navigateTo: SelectedGenderScreen(userData: userData),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'I ALREADY HAVE AN ACCOUNT',
                        navigateTo: LoginScreen(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
