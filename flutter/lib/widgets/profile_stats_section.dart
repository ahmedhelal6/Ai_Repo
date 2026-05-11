import 'package:ai_fitness_coach/models/user_data.dart';
import 'package:flutter/material.dart';

import 'profile_widgets.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({
    super.key,
    required this.userData,
  });

  final UserData userData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProfileStatCard(
            label: 'WEIGHT',
            value: userData.weight?.toString() ?? '--',
            unit: 'KG',
            icon: Icons.monitor_weight_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ProfileStatCard(
            label: 'HEIGHT',
            value: userData.height?.toString() ?? '--',
            unit: 'CM',
            icon: Icons.height_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ProfileStatCard(
            label: 'AGE',
            value: userData.age?.toString() ?? '--',
            unit: 'YRS',
            icon: Icons.cake_outlined,
          ),
        ),
      ],
    );
  }
}