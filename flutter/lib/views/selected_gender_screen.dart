import 'package:ai_fitness_coach/widgets/blur_widget.dart';
import 'package:ai_fitness_coach/widgets/custom_button_widget.dart';
import 'package:ai_fitness_coach/widgets/glass_option_widget.dart';
import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:ai_fitness_coach/views/selected_age_screen.dart';
import 'package:ai_fitness_coach/widgets/progress_bar_widget.dart';

class SelectedGenderScreen extends StatefulWidget {
  const SelectedGenderScreen({super.key, required this.userData});

  final UserData userData;

  @override
  State<SelectedGenderScreen> createState() => _SelectedGenderScreenState();
}

class _SelectedGenderScreenState extends State<SelectedGenderScreen> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.userData.gender;
  }

  void _onSelectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatedUserData = widget.userData.copyWith(
      gender: selectedGender,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(totalSteps: 5, currentStep: 1),
            const SizedBox(height: 10),
            BlurWidget(
              child: const Text(
                "What's your gender?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GlassOptionWidget(
                      title: 'Male',
                      imagePath:
                          'https://i.pinimg.com/736x/96/34/67/963467c8737f6ae283467f536b5ea040.jpg',
                      isSelected: selectedGender == 'Male',
                      onTap: () => _onSelectGender('Male'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassOptionWidget(
                      title: 'Female',
                      imagePath:
                          'https://as01.epimg.net/deporteyvida/imagenes/2017/10/26/portada/1509011082_742088_1509011342_noticia_normal.jpg',
                      isSelected: selectedGender == 'Female',
                      onTap: () => _onSelectGender('Female'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              horizontalPadding: 24,
              verticalPadding: 20,
              isEnabled: selectedGender != null,
              navigateTo: SelectedAgeScreen(userData: updatedUserData),
              text: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}