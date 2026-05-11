import 'package:ai_fitness_coach/views/signup_screen.dart';
import 'package:ai_fitness_coach/widgets/blur_widget.dart';
import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:ai_fitness_coach/widgets/goal_option_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/widgets/progress_bar_widget.dart';

class SelectedGoalScreen extends StatefulWidget {
  const SelectedGoalScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SelectedGoalScreen> createState() => _SelectedGoalScreenState();
}

class _SelectedGoalScreenState extends State<SelectedGoalScreen> {
  String? goal;

  @override
  void initState() {
    super.initState();
    goal = widget.userData.goal;
  }

  void selectGoal(String selectedGoal) {
    setState(() {
      goal = selectedGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatedUserData = widget.userData.copyWith(
      goal: goal,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(totalSteps: 5, currentStep: 5),
            const SizedBox(height: 20),
            BlurWidget(
              child: const Text(
                'What is your goal?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GoalOption(
                      title: 'Stay Fit',
                      image:
                          'https://t3.ftcdn.net/jpg/02/20/02/60/360_F_220026026_LFFqzeOwlGGhdxAQI5wvDcRUr2yUwAL8.jpg',
                      isSelected: goal == 'Stay Fit',
                      onTap: () => selectGoal('Stay Fit'),
                    ),
                    const SizedBox(height: 20),
                    GoalOption(
                      title: 'Build Muscle',
                      image:
                          'https://images.squarespace-cdn.com/content/v1/5fd8f3244930930621225e27/1608235013048-A9HX1TR0UMEZXH3VS913/image.jpg',
                      isSelected: goal == 'Build Muscle',
                      onTap: () => selectGoal('Build Muscle'),
                    ),
                    const SizedBox(height: 20),
                    GoalOption(
                      title: 'Lose Weight',
                      image:
                          'https://media.istockphoto.com/id/1186406031/photo/lonely-man-running-on-treadmill-at-the-gym.jpg?s=170667a&w=0&k=20&c=Q-qWrBU103zuAloymdoLcf7ZoaACWknKqOHNM82eiy4=',
                      isSelected: goal == 'Lose Weight',
                      onTap: () => selectGoal('Lose Weight'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            CustomButton(
              horizontalPadding: 24,
              verticalPadding: 20,
              isEnabled: goal != null,
              navigateTo: SignUpScreen(userData: updatedUserData),
              text: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}