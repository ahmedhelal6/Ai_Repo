import 'package:flutter/material.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({
    super.key,
    required this.isSecondStepActive,
  });

  final bool isSecondStepActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: isSecondStepActive ? Colors.white : Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}