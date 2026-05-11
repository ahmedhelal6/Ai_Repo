import 'package:ai_fitness_coach/models/training_plan.dart';
import 'package:flutter/material.dart';

const List<TrainingPlan> trainingPlans = [
  TrainingPlan(
    name: 'Full Body',
    subtitle: 'Simple beginner-friendly plan',
    description:
        'A simple 3-day plan that trains the whole body each session. Best for beginners or busy users.',
    level: 'Beginner',
    daysPerWeek: '3 days/week',
    icon: Icons.bolt,
    days: [
      PlanDay(
        title: 'Day 1 - Full Body A',
        focus: 'Strength basics',
        exercises: [
          'Squat',
          'Bench Press',
          'Lat Pulldown',
          'Shoulder Press',
          'Biceps Curl',
          'Plank',
        ],
      ),
      PlanDay(
        title: 'Day 2 - Full Body B',
        focus: 'Balanced muscle work',
        exercises: [
          'Leg Press',
          'Incline Dumbbell Press',
          'Seated Cable Row',
          'Lateral Raise',
          'Triceps Pushdown',
          'Crunches',
        ],
      ),
      PlanDay(
        title: 'Day 3 - Full Body C',
        focus: 'Hypertrophy and control',
        exercises: [
          'Romanian Deadlift',
          'Machine Press',
          'Pull Ups',
          'Leg Curl',
          'Hammer Curl',
          'Calf Raises',
        ],
      ),
    ],
  ),

  TrainingPlan(
    name: 'Upper Lower',
    subtitle: 'Easy split for steady progress',
    description:
        'A simple 4-day split that separates upper body and lower body training. Great after finishing beginner full body plans.',
    level: 'Beginner+',
    daysPerWeek: '4 days/week',
    icon: Icons.view_agenda,
    days: [
      PlanDay(
        title: 'Day 1 - Upper Body',
        focus: 'Chest, Back, Shoulders, Arms',
        exercises: [
          'Bench Press',
          'Lat Pulldown',
          'Shoulder Press',
          'Seated Cable Row',
          'Biceps Curl',
          'Triceps Pushdown',
        ],
      ),
      PlanDay(
        title: 'Day 2 - Lower Body',
        focus: 'Quads, Hamstrings, Calves',
        exercises: [
          'Squat',
          'Leg Press',
          'Romanian Deadlift',
          'Leg Curl',
          'Calf Raises',
          'Plank',
        ],
      ),
      PlanDay(
        title: 'Day 3 - Upper Body',
        focus: 'Upper body volume',
        exercises: [
          'Incline Dumbbell Press',
          'Barbell Row',
          'Lateral Raise',
          'Pull Ups',
          'Hammer Curl',
          'Overhead Triceps Extension',
        ],
      ),
      PlanDay(
        title: 'Day 4 - Lower Body',
        focus: 'Legs and core',
        exercises: [
          'Front Squat',
          'Walking Lunges',
          'Leg Extension',
          'Leg Curl',
          'Standing Calf Raise',
          'Crunches',
        ],
      ),
    ],
  ),

  TrainingPlan(
    name: 'Bro Split',
    subtitle: 'Classic one-muscle-per-day split',
    description:
        'A classic bodybuilding split where each day focuses on one major muscle group. Good for users who want simple focused sessions.',
    level: 'Intermediate',
    daysPerWeek: '5 days/week',
    icon: Icons.fitness_center,
    days: [
      PlanDay(
        title: 'Day 1 - Chest',
        focus: 'Chest size and pressing strength',
        exercises: [
          'Bench Press',
          'Incline Dumbbell Press',
          'Machine Press',
          'Cable Fly',
          'Dips',
        ],
      ),
      PlanDay(
        title: 'Day 2 - Back',
        focus: 'Back width and thickness',
        exercises: [
          'Lat Pulldown',
          'Pull Ups',
          'Barbell Row',
          'Seated Cable Row',
          'Dumbbell Pullover',
        ],
      ),
      PlanDay(
        title: 'Day 3 - Shoulders',
        focus: 'Shoulder width and control',
        exercises: [
          'Shoulder Press',
          'Arnold Press',
          'Lateral Raise',
          'Rear Delt Fly',
          'Shrugs',
        ],
      ),
      PlanDay(
        title: 'Day 4 - Arms',
        focus: 'Biceps and triceps',
        exercises: [
          'Biceps Curl',
          'Hammer Curl',
          'Preacher Curl',
          'Triceps Pushdown',
          'Skull Crusher',
        ],
      ),
      PlanDay(
        title: 'Day 5 - Legs',
        focus: 'Full lower body',
        exercises: [
          'Squat',
          'Leg Press',
          'Romanian Deadlift',
          'Leg Extension',
          'Calf Raises',
        ],
      ),
    ],
  ),

  TrainingPlan(
    name: 'Push Pull Legs',
    subtitle: 'Balanced strength & muscle split',
    description:
        'A structured plan that separates pushing, pulling, and leg movements. Great for building muscle with enough recovery.',
    level: 'Intermediate',
    daysPerWeek: '6 days/week',
    icon: Icons.sync_alt,
    days: [
      PlanDay(
        title: 'Day 1 - Push',
        focus: 'Chest, Shoulders, Triceps',
        exercises: [
          'Bench Press',
          'Incline Dumbbell Press',
          'Shoulder Press',
          'Lateral Raise',
          'Triceps Pushdown',
          'Dips',
        ],
      ),
      PlanDay(
        title: 'Day 2 - Pull',
        focus: 'Back, Biceps',
        exercises: [
          'Lat Pulldown',
          'Barbell Row',
          'Seated Cable Row',
          'Face Pull',
          'Biceps Curl',
          'Hammer Curl',
        ],
      ),
      PlanDay(
        title: 'Day 3 - Legs',
        focus: 'Quads, Hamstrings, Calves',
        exercises: [
          'Squat',
          'Leg Press',
          'Romanian Deadlift',
          'Leg Extension',
          'Leg Curl',
          'Calf Raises',
        ],
      ),
      PlanDay(
        title: 'Day 4 - Push',
        focus: 'Chest, Shoulders, Triceps',
        exercises: [
          'Incline Bench Press',
          'Dumbbell Press',
          'Arnold Press',
          'Cable Fly',
          'Overhead Triceps Extension',
        ],
      ),
      PlanDay(
        title: 'Day 5 - Pull',
        focus: 'Back, Biceps',
        exercises: [
          'Pull Ups',
          'T-Bar Row',
          'Single Arm Dumbbell Row',
          'Rear Delt Fly',
          'Preacher Curl',
        ],
      ),
      PlanDay(
        title: 'Day 6 - Legs',
        focus: 'Legs & Core',
        exercises: [
          'Front Squat',
          'Walking Lunges',
          'Hip Thrust',
          'Leg Curl',
          'Standing Calf Raise',
          'Plank',
        ],
      ),
    ],
  ),

  TrainingPlan(
    name: 'Arnold Split',
    subtitle: 'Classic high-volume bodybuilding plan',
    description:
        'Inspired by old-school bodybuilding. It trains opposing muscle groups together with high volume.',
    level: 'Advanced',
    daysPerWeek: '6 days/week',
    icon: Icons.local_fire_department,
    days: [
      PlanDay(
        title: 'Day 1 - Chest & Back',
        focus: 'Heavy upper body volume',
        exercises: [
          'Bench Press',
          'Incline Dumbbell Press',
          'Pull Ups',
          'Barbell Row',
          'Cable Fly',
          'Lat Pulldown',
        ],
      ),
      PlanDay(
        title: 'Day 2 - Shoulders & Arms',
        focus: 'Delts, Biceps, Triceps',
        exercises: [
          'Shoulder Press',
          'Lateral Raise',
          'Rear Delt Fly',
          'Biceps Curl',
          'Hammer Curl',
          'Triceps Pushdown',
        ],
      ),
      PlanDay(
        title: 'Day 3 - Legs',
        focus: 'Full lower body',
        exercises: [
          'Squat',
          'Leg Press',
          'Romanian Deadlift',
          'Leg Extension',
          'Leg Curl',
          'Calf Raises',
        ],
      ),
      PlanDay(
        title: 'Day 4 - Chest & Back',
        focus: 'Pump and control',
        exercises: [
          'Incline Bench Press',
          'Dumbbell Pullover',
          'Seated Cable Row',
          'Machine Press',
          'Cable Fly',
        ],
      ),
      PlanDay(
        title: 'Day 5 - Shoulders & Arms',
        focus: 'Arm size and shoulder width',
        exercises: [
          'Arnold Press',
          'Lateral Raise',
          'Preacher Curl',
          'Skull Crusher',
          'Cable Curl',
          'Rope Pushdown',
        ],
      ),
      PlanDay(
        title: 'Day 6 - Legs',
        focus: 'Quads, hamstrings, calves',
        exercises: [
          'Hack Squat',
          'Walking Lunges',
          'Leg Curl',
          'Leg Extension',
          'Seated Calf Raise',
        ],
      ),
    ],
  ),
];