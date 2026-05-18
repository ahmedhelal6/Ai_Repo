import 'package:ai_fitness_coach/controllers/workout_controller.dart';
import 'package:ai_fitness_coach/core/constants/training_plans.dart';
import 'package:ai_fitness_coach/core/constants/workout_constants.dart';
import 'package:ai_fitness_coach/models/exercise_model.dart';
import 'package:ai_fitness_coach/models/training_plan.dart';
import 'package:ai_fitness_coach/views/login_screen.dart';
import 'package:ai_fitness_coach/widgets/empty_exercises_state.dart';
import 'package:ai_fitness_coach/widgets/exercise_card.dart';
import 'package:ai_fitness_coach/widgets/exercise_details.dart';
import 'package:ai_fitness_coach/widgets/exercises_header.dart';
import 'package:ai_fitness_coach/widgets/muscle_selector_widget.dart';
import 'package:ai_fitness_coach/widgets/save_workout_bar.dart';
import 'package:ai_fitness_coach/widgets/workout_header_widget.dart';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    super.key,
    this.muscleDataJson,
  });

  final List<Map<String, dynamic>>? muscleDataJson;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final WorkoutController controller = WorkoutController();
  final TextEditingController _searchController = TextEditingController();

  late final List<Map<String, dynamic>> _data;

  String? _selectedId;
  String _searchQuery = '';
  String? _selectedEquipment;

  Set<String> _favoriteIds = {};
  bool _showFavoritesOnly = false;

  Map<String, List<ExerciseModel>> _exercisesByMuscle = {};
  List<ExerciseModel> _exercises = [];

  final List<ExerciseModel> _selectedWorkout = [];

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _data = (widget.muscleDataJson != null && widget.muscleDataJson!.isNotEmpty)
        ? widget.muscleDataJson!
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : WorkoutConstants.fallbackMuscles
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    if (_data.isNotEmpty) {
      _selectedId = _safeString(_data.first['id']);
    }

    _loadFavorites();
    _loadExercisesFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    await controller.authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  bool _isUnauthorizedMessage(String message) {
    final lowerMessage = message.toLowerCase();

    return lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('401') ||
        lowerMessage.contains('session expired') ||
        lowerMessage.contains('invalid or expired refresh token');
  }

  Future<void> _loadFavorites() async {
    final favorites = await controller.loadFavorites();

    if (!mounted) return;

    setState(() {
      _favoriteIds = favorites;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final updatedFavorites = await controller.toggleFavorite(id);

    if (!mounted) return;

    setState(() {
      _favoriteIds = updatedFavorites;
    });
  }

  List<ExerciseModel> get _filteredExercises {
    return controller.filterExercises(
      exercises: _exercises,
      searchQuery: _searchQuery,
      selectedEquipment: _selectedEquipment,
      showFavoritesOnly: _showFavoritesOnly,
      favoriteIds: _favoriteIds,
    );
  }

  List<String> get _availableEquipments {
    return controller.getAvailableEquipments(_exercises);
  }

  bool get _hasFilters {
    return _searchQuery.trim().isNotEmpty ||
        _selectedEquipment != null ||
        _showFavoritesOnly;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedEquipment = null;
      _showFavoritesOnly = false;
      _searchController.clear();
    });
  }

  Future<void> _loadExercisesFromApi() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final data = await controller.loadExercisesByMuscle();

      if (!mounted) return;

      final firstMuscleName = _data.isNotEmpty
          ? _safeString(_data.first['name']).toLowerCase().trim()
          : '';

      setState(() {
        _exercisesByMuscle = data;
        _exercises = data[firstMuscleName] ?? [];
      });
    } catch (error) {
      if (!mounted) return;

      final message = controller.getErrorMessage(error);

      if (_isUnauthorizedMessage(message)) {
        await _goToLogin();
        return;
      }

      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;

    if (_selectedWorkout.isEmpty) {
      _showSnackBar('Choose at least one exercise.');
      return;
    }

    final workoutName = await _showSaveWorkoutDialog();

    if (workoutName == null || workoutName.trim().isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _saving = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await controller.saveWorkout(
        name: workoutName,
        selectedExercises: _selectedWorkout,
      );

      if (!mounted) return;

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Workout saved successfully')),
      );
      
      navigator.pop(true);
    } catch (error) {
      if (!mounted) return;

      final message = controller.getErrorMessage(error);

      if (_isUnauthorizedMessage(message)) {
        await _goToLogin();
        return;
      }

      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<String?> _showSaveWorkoutDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => const _SaveWorkoutDialog(),
    );
  }

  void _toggleExercise(ExerciseModel exercise) {
    final id = exercise.exerciseId;

    setState(() {
      final exists = _selectedWorkout.any(
        (e) => e.exerciseId == id,
      );

      if (exists) {
        _selectedWorkout.removeWhere(
          (e) => e.exerciseId == id,
        );
      } else {
        _selectedWorkout.add(exercise);
      }
    });
  }

  bool _isExerciseAdded(ExerciseModel exercise) {
    return _selectedWorkout.any(
      (e) => e.exerciseId == exercise.exerciseId,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getMuscleImage(String name) {
    final key = name.toLowerCase().trim();
    return WorkoutConstants.muscleImages[key] ?? 'assets/images/default.png';
  }

  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  String _formatLabel(String value) {
    return value
        .toLowerCase()
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  void _showTrainingPlans(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0B0B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Training Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a ready-made split and follow it day by day.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                ...trainingPlans.map(
                  (plan) => _TrainingPlanCard(
                    plan: plan,
                    onTap: () => _showTrainingPlanDetails(context, plan),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTrainingPlanDetails(BuildContext context, TrainingPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0B0B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        plan.icon,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.level} • ${plan.daysPerWeek}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  plan.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                ...plan.days.map(
                  (day) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.focus,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...day.exercises.map(
                          (exercise) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    exercise,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    final equipments = _availableEquipments;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white54),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: .08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Favorites',
                  isSelected: _showFavoritesOnly,
                  onTap: () {
                    setState(() {
                      _showFavoritesOnly = !_showFavoritesOnly;
                    });
                  },
                ),
                if (equipments.isNotEmpty) ...[
                  _FilterChip(
                    label: 'All',
                    isSelected:
                        _selectedEquipment == null && !_showFavoritesOnly,
                    onTap: () {
                      setState(() {
                        _selectedEquipment = null;
                      });
                    },
                  ),
                  ...equipments.map(
                    (equipment) => _FilterChip(
                      label: _formatLabel(equipment),
                      isSelected: _selectedEquipment == equipment,
                      onTap: () {
                        setState(() {
                          _selectedEquipment = equipment;
                        });
                      },
                    ),
                  ),
                ],
                if (_hasFilters)
                  _FilterChip(
                    label: 'Clear',
                    isSelected: false,
                    isDanger: true,
                    onTap: _clearFilters,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        appBar: AppBar(
          backgroundColor: const Color(0xFF050505),
          title: const Text('Workout'),
        ),
        body: const SafeArea(
          child: EmptyExercisesState(),
        ),
      );
    }

    final selected = _data.firstWhere(
      (e) => _safeString(e['id']) == _selectedId,
      orElse: () => _data.first,
    );

    final selectedName = _safeString(
      selected['name'],
      fallback: 'Workout',
    );

    final filteredExercises = _filteredExercises;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        title: const Text('Workout'),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => _showTrainingPlans(context),
          backgroundColor: Colors.redAccent,
          elevation: 12,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.assignment,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const WorkoutHeader(),
            _buildSearchAndFilters(),
            MuscleSelector(
              data: _data,
              selectedId: _selectedId,
              getMuscleImage: getMuscleImage,
              onSelect: (id, name) {
                final key = name.toLowerCase().trim();

                setState(() {
                  _selectedId = id;
                  _selectedEquipment = null;
                  _exercises = _exercisesByMuscle[key] ?? [];
                });
              },
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredExercises.isEmpty
                      ? const EmptyExercisesState()
                      : Column(
                          children: [
                            ExercisesHeader(
                              muscleName: selectedName,
                              count: filteredExercises.length,
                            ),
                            Expanded(
                              child: GridView.builder(
                                itemCount: filteredExercises.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: 340,
                                ),
                                itemBuilder: (_, index) {
                                  final exercise = filteredExercises[index];

                                  return ExerciseCard(
                                    exercise: exercise,
                                    muscleName: selectedName,
                                    isAdded: _isExerciseAdded(exercise),
                                    isFavorite: _favoriteIds.contains(
                                      exercise.exerciseId,
                                    ),
                                    formatLabel: _formatLabel,
                                    defaultExerciseImage:
                                        WorkoutConstants.defaultExerciseImage,
                                    onToggle: () => _toggleExercise(exercise),
                                    onFavoriteToggle: () =>
                                        _toggleFavorite(exercise.exerciseId),
                                    onOpenDetails: () async {
                                      final added =
                                          await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ExerciseDetailsScreen(
                                            exercise: exercise.toJson(),
                                            muscleName: selectedName,
                                            imagePath: exercise.imageUrl,
                                            isAdded:
                                                _isExerciseAdded(exercise),
                                          ),
                                        ),
                                      );

                                      if (added == null) return;

                                      final exists =
                                          _isExerciseAdded(exercise);

                                      if (added && !exists) {
                                        _toggleExercise(exercise);
                                      } else if (!added && exists) {
                                        _toggleExercise(exercise);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _selectedWorkout.isEmpty
          ? null
          : SaveWorkoutBar(
              count: _selectedWorkout.length,
              onSave: _saving ? () {} : _saveWorkout,
            ),
    );
  }
}

class _TrainingPlanCard extends StatelessWidget {
  const _TrainingPlanCard({
    required this.plan,
    required this.onTap,
  });

  final TrainingPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalExercises = plan.days.fold<int>(
      0,
      (sum, day) => sum + day.exercises.length,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: .08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                plan.icon,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PlanBadge(text: plan.level),
                      _PlanBadge(text: plan.daysPerWeek),
                      _PlanBadge(text: '$totalExercises exercises'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFFFF4B4B)
        : Colors.white.withValues(alpha: .08);

    final borderColor = isSelected
        ? const Color(0xFFFF4B4B)
        : Colors.white.withValues(alpha: .12);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                isDanger ? Colors.red.withValues(alpha: .14) : backgroundColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isDanger ? Colors.redAccent : borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isDanger ? Colors.redAccent : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveWorkoutDialog extends StatefulWidget {
  const _SaveWorkoutDialog();

  @override
  State<_SaveWorkoutDialog> createState() => _SaveWorkoutDialogState();
}

class _SaveWorkoutDialogState extends State<_SaveWorkoutDialog> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: const Text(
        'Save Workout',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Workout name',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: .06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter workout name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _textController.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}