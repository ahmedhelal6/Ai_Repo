import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// =========================================================
// CONFIG — غيّر الـ IP لو التليفون والـ PC على نفس الـ WiFi
// =========================================================
const String _kPythonHost = '192.168.1.12'; // Android emulator → localhost
// const String _kPythonHost = '192.168.1.X'; // جهاز حقيقي
const int _kPythonPort = 8000;

// =========================================================
// AI COACH SCREEN
// =========================================================
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen>
    with WidgetsBindingObserver {
  // ----- Camera -----
  CameraController? _camera;
  bool _cameraReady = false;

  // ----- ML Kit -----
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  bool _isProcessing = false;
  DateTime? _lastSentTime;

  // ----- WebSocket -----
  WebSocketChannel? _channel;
  bool _wsConnected = false;

  // ----- Result State -----
  String _exercise = '—';
  String _state = 'Connecting...';
  int _reps = 0;
  String? _stage;
  List<String> _feedback = [];
  bool _locked = false;
  double _confidence = 0.0;
  bool _awaitingDecision = false;
  bool _showReport = false;
  Map<String, dynamic> _reportData = {};

  // =====================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    _poseDetector.close();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_camera == null || !_camera!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _camera!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // =====================================================
  // INIT
  // =====================================================
  Future<void> _initAll() async {
    await _initCamera();
    _initWebSocket();
  }

  void _sendAction(String command) {
    if (_wsConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({'command': command}));
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // استخدم الكاميرا الأمامية
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _camera = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    await _camera!.initialize();

    if (!mounted) return;

    setState(() => _cameraReady = true);

    _camera!.startImageStream(_onCameraFrame);
  }

  void _initWebSocket() {
    try {
      final uri = Uri.parse('ws://$_kPythonHost:$_kPythonPort/ws/flutter_user');
      _channel = WebSocketChannel.connect(uri);

      setState(() => _wsConnected = true);

      // استقبال النتائج من Python
      _channel!.stream.listen(
        _onResult,
        onError: (_) => setState(() => _wsConnected = false),
        onDone: () => setState(() => _wsConnected = false),
      );
    } catch (_) {
      setState(() => _wsConnected = false);
    }
  }

  // =====================================================
  // CAMERA FRAME → ML Kit → WebSocket
  // =====================================================
  Future<void> _onCameraFrame(CameraImage image) async {
    final now = DateTime.now();

    if (_isProcessing || !_wsConnected || _awaitingDecision || _showReport) return;
    _isProcessing = true;
    _lastSentTime = now;

    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return;

      final keypoints = _poseToJson(poses.first, image.width.toDouble(), image.height.toDouble());
      
      // بعت الـ keypoints كـ Binary (أسرع بكتير من الـ JSON)
      _channel!.sink.add(keypoints.buffer.asUint8List());
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    if (_camera == null) return null;

    final camera = _camera!.description;
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Float32List _poseToJson(Pose pose, double width, double height) {
    // هنبعت 132 رقم بصيغة Float32 (33 نقطة * 4 قيم)
    final flatList = Float32List(132);
    int pointer = 0;

    for (int i = 0; i < 33; i++) {
      final lm = pose.landmarks[PoseLandmarkType.values[i]];
      if (lm != null) {
        flatList[pointer++] = (lm.x / width);
        flatList[pointer++] = (lm.y / height);
        flatList[pointer++] = (lm.z / width);
        flatList[pointer++] = lm.likelihood;
      } else {
        pointer += 4; // بيفضلوا 0.0
      }
    }
    return flatList;
  }

  // =====================================================
  // RESULT FROM PYTHON
  // =====================================================
  void _onResult(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;

      if (data['type'] == 'REPORT') {
        setState(() {
          _showReport = true;
          _awaitingDecision = false;
          _reportData = data['data'] ?? {};
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _state = data['state'] ?? '—';
        _exercise = _formatExercise(data['exercise'] ?? '—');
        _reps = data['reps'] ?? 0;
        _stage = data['stage'];
        _locked = data['locked'] ?? false;
        _confidence = (data['confidence'] ?? 0.0).toDouble();
        _feedback = List<String>.from(data['feedback'] ?? []);
        _awaitingDecision = data['awaiting_decision'] ?? false;
        _showReport = data['show_report'] ?? false;
      });
    } catch (_) {}
  }

  String _formatExercise(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------
          // Camera Preview
          // ------------------------------------------------
          if (_cameraReady && _camera != null)
            CameraPreview(_camera!)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),

          // ------------------------------------------------
          // HUD Overlay
          // ------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildFeedbackBanner(),
                _buildBottomHUD(),
              ],
            ),
          ),

          // ------------------------------------------------
          // Overlays (Top-most)
          // ------------------------------------------------
          _buildCountdownOverlay(),
          _buildDecisionOverlay(),
          _buildReportOverlay(),
        ],
      ),
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),

          // Title + State
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Coach',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _stateLabel,
                  style: TextStyle(
                    color: _stateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Connection indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _wsConnected ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FEEDBACK BANNER
  // =====================================================
  Widget _buildFeedbackBanner() {
    if (_feedback.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _feedback.first,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BOTTOM HUD
  // =====================================================
  Widget _buildBottomHUD() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Exercise
          _HUDItem(
            label: 'Exercise',
            value: _locked ? _exercise : '—',
            icon: Icons.fitness_center,
            color: Colors.redAccent,
          ),

          // Reps
          _HUDItem(
            label: 'Reps',
            value: '$_reps',
            icon: Icons.repeat,
            color: Colors.greenAccent,
          ),

          // Stage
          _HUDItem(
            label: 'Stage',
            value: _stage?.toUpperCase() ?? '—',
            icon: Icons.arrow_upward,
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================
  String get _stateLabel {
    if (!_wsConnected) return '● Not connected to Python';
    switch (_state) {
      case 'MOVE_TO_START':
        return '● Move to start position';
      case 'BUFFERING':
        return '● Analyzing movement...';
      case 'ACTIVE':
        return _locked
            ? '● Tracking: $_exercise'
            : '● Detecting exercise...';
      default:
        if (_state.startsWith('COUNTDOWN_')) {
          final n = _state.split('_').last;
          return '● Starting in $n...';
        }
        return '● $_state';
    }
  }

  Color get _stateColor {
    if (!_wsConnected) return Colors.redAccent;
    if (_state == 'ACTIVE' && _locked) return Colors.greenAccent;
    if (_state == 'BUFFERING') return Colors.orangeAccent;
    return Colors.white54;
  }

  // =====================================================
  // OVERLAYS
  // =====================================================

  Widget _buildCountdownOverlay() {
    if (!_state.startsWith('COUNTDOWN_')) return const SizedBox.shrink();
    final n = _state.split('_').last;

    return Container(
      color: Colors.black45,
      child: Center(
        child: Text(
          n,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 180,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionOverlay() {
    if (!_awaitingDecision) return const SizedBox.shrink();

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.redAccent.withValues(alpha: .3), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SESSION PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an action to continue',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDecisionButton(
                    label: 'RESUME',
                    icon: Icons.play_arrow_rounded,
                    color: Colors.greenAccent,
                    onTap: () {
                      _sendAction('resume');
                    },
                  ),
                  _buildDecisionButton(
                    label: 'RESTART',
                    icon: Icons.refresh_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {
                      _sendAction('restart');
                    },
                  ),
                  _buildDecisionButton(
                    label: 'FINISH',
                    icon: Icons.stop_rounded,
                    color: Colors.redAccent,
                    onTap: () => _sendAction('finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: .3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOverlay() {
    if (!_showReport) return const SizedBox.shrink();

    final history = _reportData['workout_history'] as List<dynamic>? ?? [];

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WORKOUT REPORT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          'No exercises recorded yet.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index] as Map<String, dynamic>;
                          final name = (item['exercise'] ?? '—') as String;
                          final reps = item['total_reps'] ?? 0;
                          final goodForm = item['good_form'] ?? true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toUpperCase().replaceAll('_', ' '),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        goodForm == true ? '✅ Good Form' : '⚠️ Needs Improvement',
                                        style: TextStyle(
                                          color: goodForm == true ? Colors.greenAccent : Colors.orangeAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$reps',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// =========================================================
// HUD ITEM WIDGET
// =========================================================
class _HUDItem extends StatelessWidget {
  const _HUDItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}