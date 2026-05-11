import 'package:ai_fitness_coach/widgets/blur_widget.dart';
import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/selected_height_screen.dart';
import 'package:ai_fitness_coach/widgets/progress_bar_widget.dart';
import 'package:ai_fitness_coach/widgets/number_picker_widget.dart';

class SelectedAgeScreen extends StatefulWidget {
  const SelectedAgeScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SelectedAgeScreen> createState() => _SelectedAgeScreenState();
}

class _SelectedAgeScreenState extends State<SelectedAgeScreen> {
  late int age;

  @override
  void initState() {
    super.initState();
    age = widget.userData.age ?? 20;
  }

  @override
  Widget build(BuildContext context) {
    final updatedUserData = widget.userData.copyWith(age: age);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(totalSteps: 5, currentStep: 2),
            const SizedBox(height: 20),

            BlurWidget(
              child: const Text(
                'How old are you?',
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
                      min: 10,
                      max: 100,
                      initialValue: age,
                      unit: '',
                      onChanged: (value) {
                        setState(() {
                          age = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            CustomButton(
              horizontalPadding: 24,
              verticalPadding: 20,
              navigateTo: SelectedHeightScreen(userData: updatedUserData),
              text: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}