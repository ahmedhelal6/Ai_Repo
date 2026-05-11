import 'package:ai_fitness_coach/widgets/blur_widget.dart';
import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/selected_weight_screen.dart';
import 'package:ai_fitness_coach/widgets/progress_bar_widget.dart';
import 'package:ai_fitness_coach/widgets/number_picker_widget.dart';

class SelectedHeightScreen extends StatefulWidget {
  const SelectedHeightScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SelectedHeightScreen> createState() => _SelectedHeightScreenState();
}

class _SelectedHeightScreenState extends State<SelectedHeightScreen> {
  late int height;

  @override
  void initState() {
    super.initState();
    height = widget.userData.height ?? 170;
  }

  @override
  Widget build(BuildContext context) {
    final updatedUserData = widget.userData.copyWith(
      height: height,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(totalSteps: 5, currentStep: 3),
            const SizedBox(height: 20),
            BlurWidget(
              child: const Text(
                'What is your height?',
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Center(
                    child: NumberPickerWidget(
                      min: 120,
                      max: 220,
                      initialValue: height,
                      unit: 'cm',
                      onChanged: (value) {
                        setState(() {
                          height = value;
                        });
                      },
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
                navigateTo: SelectedWeightScreen(userData: updatedUserData),
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}