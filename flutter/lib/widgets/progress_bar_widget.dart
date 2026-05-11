import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double progressWidth =
              (constraints.maxWidth / totalSteps) * currentStep;

          return Stack(
            children: [
              // الخلفية
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // الـ progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: progressWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}