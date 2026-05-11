import 'package:flutter/material.dart';

class TrainingPlan {
  final String name;
  final String subtitle;
  final String description;
  final String level;
  final String daysPerWeek;
  final IconData icon;
  final List<PlanDay> days;

  const TrainingPlan({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.level,
    required this.daysPerWeek,
    required this.icon,
    required this.days,
  });
}

class PlanDay {
  final String title;
  final String focus;
  final List<String> exercises;

  const PlanDay({
    required this.title,
    required this.focus,
    required this.exercises,
  });
}