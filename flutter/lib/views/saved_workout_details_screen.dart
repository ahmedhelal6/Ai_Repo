import 'package:ai_fitness_coach/controllers/session_controller.dart';
import 'package:ai_fitness_coach/models/exercise_model.dart';
import 'package:ai_fitness_coach/models/exercise_set.dart';
import 'package:ai_fitness_coach/models/workout_model.dart';
import 'package:ai_fitness_coach/widgets/exercise_details.dart';
import 'package:flutter/material.dart';

class ExerciseSetInput {
  final TextEditingController weight;
  final TextEditingController reps;

  ExerciseSetInput({
    required this.weight,
    required this.reps,
  });

  void dispose() {
    weight.dispose();
    reps.dispose();
  }
}

class SavedWorkoutDetailsScreen extends StatefulWidget {
  const SavedWorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  final WorkoutModel workout;

  @override
  State<SavedWorkoutDetailsScreen> createState() =>
      _SavedWorkoutDetailsScreenState();
}

class _SavedWorkoutDetailsScreenState extends State<SavedWorkoutDetailsScreen> {
  final SessionController controller = SessionController();

  List<bool> _expandedList = [];
  List<List<ExerciseSetInput>> _exerciseSets = [];
  late List<ExerciseModel> _exercises;

  bool _savingSession = false;

  @override
  void initState() {
    super.initState();

    _exercises = widget.workout.exercises
        .map((exercise) => ExerciseModel.fromJson(exercise.toJson()))
        .toList();

    _ensureListsInitialized();
  }

  @override
  void dispose() {
    _disposeAllControllers();
    super.dispose();
  }

  void _ensureListsInitialized() {
    if (_expandedList.length != _exercises.length) {
      _expandedList = List<bool>.filled(_exercises.length, false);
    }

    if (_exerciseSets.length != _exercises.length) {
      _disposeAllControllers();

      _exerciseSets = List.generate(
        _exercises.length,
        (index) {
          if (_exercises[index].sets.isNotEmpty) {
            return _exercises[index]
                .sets
                .map(
                  (set) => _createSetControllers(
                    weight: set.weight.toString(),
                    reps: set.reps.toString(),
                  ),
                )
                .toList();
          }

          return [
            _createSetControllers(),
          ];
        },
      );
    }
  }

  ExerciseSetInput _createSetControllers({
    String weight = '',
    String reps = '',
  }) {
    return ExerciseSetInput(
      weight: TextEditingController(text: weight),
      reps: TextEditingController(text: reps),
    );
  }

  void _disposeAllControllers() {
    for (var exercise in _exerciseSets) {
      for (var setRow in exercise) {
        setRow.dispose();
      }
    }
  }

  void _addSetRow(int exerciseIndex) {
    setState(() {
      _exerciseSets[exerciseIndex].add(_createSetControllers());
    });
  }

  void _removeSetRow(int exerciseIndex, int setIndex) {
    if (_exerciseSets[exerciseIndex].length <= 1) return;

    final row = _exerciseSets[exerciseIndex][setIndex];
    row.dispose();

    setState(() {
      _exerciseSets[exerciseIndex].removeAt(setIndex);
    });
  }

  Future<void> _submitSession() async {
    if (_savingSession) return;

    setState(() {
      _savingSession = true;
    });

    try {
      final sets = _readExerciseSets();

      await controller.submitSession(
        workoutId: widget.workout.id,
        baseExercises: _exercises,
        sets: sets,
      );

      if (!mounted) return;

      _showSnackBar(
        message: 'Session saved successfully',
        backgroundColor: Colors.green,
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        message: controller.getErrorMessage(error),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingSession = false;
        });
      }
    }
  }

  List<List<ExerciseSet>> _readExerciseSets() {
    final List<List<ExerciseSet>> result = [];

    for (var exerciseRows in _exerciseSets) {
      final List<ExerciseSet> sets = [];

      for (var row in exerciseRows) {
        final weightRaw = double.tryParse(row.weight.text.trim()) ?? 0.0;
        final repsRaw = int.tryParse(row.reps.text.trim()) ?? 0;

        final weight = weightRaw < 0 ? 0.0 : weightRaw;
        final reps = repsRaw < 0 ? 0 : repsRaw;

        sets.add(
          ExerciseSet(
            weight: weight,
            reps: reps,
            isCompleted: reps > 0,
          ),
        );
      }

      result.add(sets);
    }

    return result;
  }

  void _openExerciseVideo(ExerciseModel exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailsScreen(
          exercise: exercise.toJson(),
          muscleName: exercise.targetMuscles.isNotEmpty
              ? exercise.targetMuscles.first
              : '',
          imagePath: exercise.imageUrl,
          isAdded: true,
        ),
      ),
    );
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Widget _buildExerciseImage(ExerciseModel exercise) {
    final imageUrl = exercise.imageUrl.trim();

    return GestureDetector(
      onTap: () => _openExerciseVideo(exercise),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          color: const Color(0xFF1A1A1A),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.fitness_center,
                  color: Colors.white70,
                )
              : _isNetworkImage(imageUrl)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.fitness_center,
                          color: Colors.white70,
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.fitness_center,
                          color: Colors.white70,
                        );
                      },
                    ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 12,
      ),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFFF4B2B),
          width: 1.2,
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Set',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Kg',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reps',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex) {
    final rowControllers = _exerciseSets[exerciseIndex][setIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${setIndex + 1}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              controller: rowControllers.weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: _inputDecoration('0'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: rowControllers.reps,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: _inputDecoration('0'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeSetRow(exerciseIndex, setIndex),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white60,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index) {
    final exercise = _exercises[index];
    final isExpanded = _expandedList[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFFFF4B2B).withValues(alpha: .4)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _expandedList[index] = !isExpanded;
              });
            },
            leading: _buildExerciseImage(exercise),
            title: Text(
              exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${exercise.targetMuscles.isNotEmpty ? exercise.targetMuscles.first : ""} • ${exercise.equipments.isNotEmpty ? exercise.equipments.first : ""}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.white70,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  ...List.generate(
                    _exerciseSets[index].length,
                    (setIndex) => _buildSetRow(index, setIndex),
                  ),
                  TextButton.icon(
                    onPressed: () => _addSetRow(index),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Set'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4B2B),
                    ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        elevation: 0,
        title: Text(
          '${widget.workout.name} Session',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _savingSession ? null : _submitSession,
              child: Text(
                _savingSession ? 'SAVING...' : 'SAVE',
                style: TextStyle(
                  color: _savingSession
                      ? Colors.white38
                      : const Color(0xFFFF4B2B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _exercises.isEmpty
          ? const Center(
              child: Text(
                'No exercises found',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildExerciseCard(index);
              },
            ),
    );
  }
}