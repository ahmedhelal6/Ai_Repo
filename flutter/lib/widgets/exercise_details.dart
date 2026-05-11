import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    required this.muscleName,
    required this.imagePath,
    required this.isAdded,
  });

  final Map<String, dynamic> exercise;
  final String muscleName;
  final String imagePath;
  final bool isAdded;

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  OmniPlaybackController? _controller;
  late bool isAdded;

  @override
  void initState() {
    super.initState();
    isAdded = widget.isAdded;
  }

  @override
void dispose() {
  if (_controller != null) {
    _controller = null;
  }
  super.dispose();
}  

  @override
  Widget build(BuildContext context) {
    final name = _safeString(widget.exercise['name'], fallback: 'Exercise');
    final videoUrl = _safeString(
      widget.exercise['videoUrl'] ?? widget.exercise['video'],
    );
    final targetMuscles = _asStringList(widget.exercise['targetMuscles']);
    final equipments = _asStringList(widget.exercise['equipments']);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        elevation: 0,
        title: const Text(
          'Exercise Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          children: [
            _buildVideo(videoUrl),
            const SizedBox(height: 22),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.muscleName,
              style: const TextStyle(
                color: Color(0xFFFF5A4E),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            _InfoSection(
              title: 'Target Muscles',
              items: targetMuscles,
              icon: Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Equipments',
              items: equipments,
              icon: Icons.sports_gymnastics_rounded,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAdded = !isAdded;
                  });

                  Navigator.pop(context, isAdded);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAdded ? Colors.green : const Color(0xFFFF5A4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  isAdded ? 'Added to Workout' : 'Add to Workout',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo(String videoUrl) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: videoUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white54,
                size: 78,
              ),
            )
          : OmniVideoPlayer(
              callbacks: VideoPlayerCallbacks(
                onControllerCreated: (controller) {
                  _controller = controller;
                },
              ),
              configuration: VideoPlayerConfiguration(
                videoSourceConfiguration: VideoSourceConfiguration.youtube(
                  videoUrl: Uri.parse(videoUrl),
                  enableYoutubeWebViewFallback: true,
                  forceYoutubeWebViewOnly: false,
                  preferredQualities: const [
                    OmniVideoQuality.medium360,
                  ],
                  availableQualities: const [
                    OmniVideoQuality.medium360,
                    OmniVideoQuality.low144,
                  ],
                ).copyWith(
                  autoPlay: false,
                  initialVolume: 1,
                ),
                playerUIVisibilityOptions: PlayerUIVisibilityOptions().copyWith(
                  showSeekBar: true,
                  showCurrentTime: true,
                  showDurationTime: true,
                  showFullScreenButton: true,
                  showPlayPauseReplayButton: true,
                  showVideoBottomControlsBar: true,
                  fitVideoToBounds: true,
                ),
              ),
            ),
    );
  }

  String _safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A4E).withValues(alpha: .14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF5A4E),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  items.map(_formatLabel).join(' • '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}