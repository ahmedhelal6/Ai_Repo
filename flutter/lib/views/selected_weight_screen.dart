import 'dart:ui';

import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/selected_goal_screen.dart';
import 'package:ai_fitness_coach/widgets/progress_bar_widget.dart';
import 'package:ai_fitness_coach/widgets/number_picker_widget.dart';

class SelectedWeightScreen extends StatefulWidget {
  const SelectedWeightScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SelectedWeightScreen> createState() => _SelectedWeightScreenState();
}

class _SelectedWeightScreenState extends State<SelectedWeightScreen> {
  late int weight;

  @override
  void initState() {
    super.initState();
    weight = widget.userData.weight ?? 70;
  }

  @override
  Widget build(BuildContext context) {
    final updatedUserData = widget.userData.copyWith(
      weight: weight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(totalSteps: 5, currentStep: 4),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black.withValues(alpha: .3),
              child: const Text(
                'What is your weight?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Center(
                        child: NumberPickerWidget(
                          min: 30,
                          max: 180,
                          initialValue: weight,
                          unit: 'kg',
                          onChanged: (value) {
                            setState(() {
                              weight = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: CustomButton(
                isEnabled: true,
                navigateTo: SelectedGoalScreen(userData: updatedUserData),
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}