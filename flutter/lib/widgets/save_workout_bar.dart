import 'package:flutter/material.dart';

class SaveWorkoutBar extends StatelessWidget {
  const SaveWorkoutBar({
    super.key,
    required this.count,
    required this.onSave,
  });

  final int count;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$count exercises added',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B3A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}