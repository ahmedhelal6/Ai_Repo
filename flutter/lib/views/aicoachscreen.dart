import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';

/// Device rotation → degrees (Android ML Kit `InputImage`, see google_ml_kit example).
final Map<DeviceOrientation, int> _deviceOrientationDegrees = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

// =========================================================
// CONFIG — غيّر الـ IP لو التليفون والـ PC على نفس الـ WiFi
// =========================================================
const String _kPythonHost = '192.168.1.12'; 
// const String _kPythonHost = '10.0.2.2'; 
const int _kPythonPort = 8000;

const Duration _kCameraInitTimeout = Duration(seconds: 25);

// =========================================================
// EMULATOR CAMERA COMPENSATION
// Adjust _kCameraOffsetX to center the camera on your emulator.
// Positive = shift view right, Negative = shift left.
// Set to 0.0 when running on a real phone.
// =========================================================
const double _kCameraOffsetX = 0.0;
const double _kCameraScale = 1.0;

/// Try lower resolutions after failures (emulators often fail `open | onError` on medium/front).
const List<ResolutionPreset> _coachResolutionOrder = [
  ResolutionPreset.medium,
  ResolutionPreset.low,
  ResolutionPreset.high,
];

List<CameraDescription> _coachCameraOrder(List<CameraDescription> cameras) {
  int lensRank(CameraDescription c) {
    switch (c.lensDirection) {
      case CameraLensDirection.front:
        return 0;
      case CameraLensDirection.back:
        return 1;
      case CameraLensDirection.external:
        return 2;
    }
  }

  final sorted = [...cameras]..sort((a, b) {
    final d = lensRank(a).compareTo(lensRank(b));
    return d != 0 ? d : a.name.compareTo(b.name);
  });
  return sorted;
}

// =========================================================
// AI COACH SCREEN
// =========================================================
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  // ----- Camera -----
  CameraController? _camera;
  bool _cameraReady = false;
  String? _cameraError;

  // ----- ML Kit -----
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  bool _isProcessing = false;
  DateTime? _lastSentTime;

  // ----- WebSocket -----
  IOWebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  Timer? _reconnectTimer;
  bool _wsConnected = false;
  bool _wsConnecting = false;
  int _reconnectAttempts = 0;

  // ----- Result State -----
  String _exercise = '—';
  String _state = 'BOOT';
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
    _initAll();
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _wsSub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _camera?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  // =====================================================
  // INIT
  // =====================================================
  void _initAll() {
    unawaited(_connectWebSocket());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initCamera());
    });
  }

  void _sendAction(String command) {
    final ch = _channel;
    if (!_wsConnected || ch == null) return;
    try {
      ch.sink.add(jsonEncode({'command': command}));
    } catch (e) {
      debugPrint('WS send action failed: $e');
    }
  }

  Future<void> _initCamera() async {
    await _disposeCameraQuiet();
    if (!mounted) return;

    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _cameraError = status.isPermanentlyDenied
                ? 'Camera blocked. Allow it from system app settings.'
                : 'Camera permission is required for AI Coach.';
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _cameraReady = false;
        _cameraError = null;
      });
    }

    late final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras().timeout(_kCameraInitTimeout);
    } on TimeoutException catch (e, st) {
      debugPrint('availableCameras timeout: $e\n$st');
      await _disposeCameraQuiet();
      if (mounted) {
        setState(
          () =>
              _cameraError = 'Camera service took too long. Cold-boot the emulator or Retry.',
        );
      }
      return;
    }

    try {
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'No cameras found');
        return;
      }

      final cameraOrder = _coachCameraOrder(cameras);

      Object? lastError;

      outer:
      for (final cam in cameraOrder) {
        for (final preset in _coachResolutionOrder) {
          if (!mounted) return;

          await _disposeCameraQuiet();
          try {
            debugPrint(
              'Camera trial: lens=${cam.lensDirection.name} '
              'id=${cam.name} preset=${preset.name}',
            );

            _camera = CameraController(
              cam,
              preset,
              enableAudio: false,
              imageFormatGroup:
                  Platform.isIOS
                      ? ImageFormatGroup.bgra8888
                      : ImageFormatGroup.nv21,
            );

            await _camera!.initialize().timeout(_kCameraInitTimeout);

            if (!mounted) break outer;

            await _camera!.startImageStream(_onCameraFrame).timeout(_kCameraInitTimeout);

            if (!mounted) break outer;

            setState(() {
              _cameraReady = true;
              _cameraError = null;
            });

            debugPrint('Camera OK: ${cam.name} @ ${preset.name}');
            return;
          } on TimeoutException catch (e, st) {
            debugPrint('Camera trial timeout (${cam.name} ${preset.name}): $e\n$st');
            lastError = e;
          } catch (e, st) {
            debugPrint(
              'Camera trial failed (${cam.name} ${preset.name}): '
              '${e.runtimeType}: $e\n$st',
            );
            lastError = e;
          }
        }
      }

      await _disposeCameraQuiet();
      if (mounted) {
        final emuTip =
            Platform.isAndroid
                ? '\n\nIf you use Android Emulator: Extended controls ⋮ → '
                    'Camera → assign Webcam/virtual camera to Front and Back.'
                : '';
        if (lastError is TimeoutException) {
          setState(() => _cameraError = 'Camera took too long to start. Retry.$emuTip');
        } else if (lastError != null) {
          setState(
            () =>
                _cameraError = 'Could not open any camera (${lastError.runtimeType}).$emuTip',
          );
        } else {
          setState(() => _cameraError = 'Could not open camera.$emuTip');
        }
      }
    } catch (e, st) {
      debugPrint('Unexpected camera setup error: $e\n$st');
      await _disposeCameraQuiet();
      if (mounted) {
        setState(() => _cameraError = 'Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _disposeCameraQuiet() async {
    try {
      await _camera?.dispose();
    } catch (_) {}
    _camera = null;
    _cameraReady = false;
  }

  Future<void> _disposeWebSocket({bool rebuildUi = true}) async {
    final wasConnected = _wsConnected;
    await _wsSub?.cancel();
    _wsSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _wsConnected = false;
    if (rebuildUi && mounted && wasConnected) setState(() {});
  }

  Duration _wsReconnectDelay() {
    const caps = [1, 2, 4, 8, 16, 32];
    final idx = min(_reconnectAttempts, caps.length - 1);
    return Duration(seconds: caps[idx]);
  }

  void _scheduleWebSocketReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_wsReconnectDelay(), () {
      if (!mounted) return;
      _reconnectAttempts = min(_reconnectAttempts + 1, 8);
      unawaited(_connectWebSocket());
    });
  }

  /// Opens the WS after TCP + WebSocket handshake (no need to wait for the first JSON from Python).
  Future<void> _connectWebSocket({bool manual = false}) async {
    if (_wsConnecting || !mounted) return;
    if (manual) {
      _reconnectTimer?.cancel();
      _reconnectAttempts = 0;
    }

    _wsConnecting = true;
    await _disposeWebSocket(rebuildUi: true);

    final uriStr = 'ws://$_kPythonHost:$_kPythonPort/ws/flutter_user';
    debugPrint('Connecting to WebSocket: $uriStr');

    try {
      final ws = await WebSocket.connect(uriStr);
      if (!mounted) {
        await ws.close();
        return;
      }

      _channel = IOWebSocketChannel(ws);
      if (mounted) {
        setState(() {
          _wsConnected = true;
          _reconnectAttempts = 0;
        });
      }

      _wsSub = _channel!.stream.listen(
        _onWsMessage,
        onError: (Object err, StackTrace st) {
          debugPrint('WS Error: $err');
          if (!mounted) return;
          unawaited(_disposeWebSocket(rebuildUi: true));
          _scheduleWebSocketReconnect();
        },
        onDone: () {
          debugPrint('WS Connection Closed');
          if (!mounted) return;
          unawaited(_disposeWebSocket(rebuildUi: true));
          _scheduleWebSocketReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WS connect failed: $e');
      if (mounted) _scheduleWebSocketReconnect();
    } finally {
      _wsConnecting = false;
    }
  }

  void _onWsMessage(dynamic data) {
    if (!mounted) return;
    final payload = data is String
        ? data
        : (data is List<int> ? utf8.decode(data, allowMalformed: true) : null);
    if (payload != null && payload.isNotEmpty) {
      _onResult(payload);
    }
  }

  Future<void> _manualReconnectWs() async {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    await _connectWebSocket(manual: true);
  }

  // =====================================================
  // CAMERA FRAME → ML Kit → WebSocket
  // =====================================================
  Future<void> _onCameraFrame(CameraImage image) async {
    if (_isProcessing || !_wsConnected || _showReport) return;

    // Throttle pose pipeline (preview still runs at device rate).
    final now = DateTime.now();
    if (_lastSentTime != null && now.difference(_lastSentTime!).inMilliseconds < 150) {
      return;
    }

    _isProcessing = true;
    _lastSentTime = now;

    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return;

      final keypoints = _poseToJson(poses.first, image.width.toDouble(), image.height.toDouble());
      final ch = _channel;
      if (!mounted || ch == null || !_wsConnected) return;
      try {
        ch.sink.add(keypoints.buffer.asUint8List());
      } catch (e) {
        debugPrint('WS send frame failed: $e');
      }
    } catch (e) {
      debugPrint('Frame Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final controller = _camera;
    if (controller == null || !controller.value.isInitialized) return null;

    final cameraDesc = controller.description;
    final sensorOrientation = cameraDesc.sensorOrientation;

    // Match google_ml_kit example (`camera_view.dart`): NV21 + rotation compensation on Android.
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final deviceRotation = _deviceOrientationDegrees[controller.value.deviceOrientation];
      if (deviceRotation == null) return null;

      final int rotationCompensation;
      if (cameraDesc.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + deviceRotation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - deviceRotation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }
    if (image.planes.length != 1) return null;

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
        final nextState = data['state'];
        _state =
            nextState is String && nextState.isNotEmpty ? nextState : 'SERVER_UPDATE';
        _exercise = _formatExercise(data['exercise'] ?? '—');
        _reps = data['reps'] ?? 0;
        _stage = data['stage'];
        _locked = data['locked'] ?? false;
        _confidence = (data['confidence'] ?? 0.0).toDouble();
        _feedback = List<String>.from(data['feedback'] ?? []);
        _awaitingDecision = data['awaiting_decision'] ?? false;
        _showReport = data['show_report'] ?? false;
      });
    } catch (e, st) {
      debugPrint('AI Coach reply parse failed: $e\n$st');
    }
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
            SizedBox.expand(
              child: CameraPreview(_camera!),
            )
          else if (_cameraError != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Camera Error: $_cameraError', style: const TextStyle(color: Colors.white)),
                  TextButton(onPressed: _initCamera, child: const Text('Retry Camera')),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),

          // ------------------------------------------------
          // WebSocket Status & Overlay
          // ------------------------------------------------
          if (!_wsConnected)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text('Not connected to Python Server', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Host: $_kPythonHost', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _manualReconnectWs(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Try to Reconnect'),
                    ),
                  ],
                ),
              ),
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
      case 'BOOT':
        return '● Preparing…';
      case 'CONNECTED':
        return '● Connected — stand in camera view';
      case 'SERVER_UPDATE':
        return '● Updating session…';
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
    final summary = _reportData['summary'] as Map<String, dynamic>? ?? {};

    final totalReps = summary['total_reps'] ?? 0;
    final totalGood = summary['total_good_reps'] ?? 0;
    final totalBad = summary['total_bad_reps'] ?? 0;
    final overallScore = summary['overall_form_score'] ?? 100;

    Color scoreColor(int score) {
      if (score >= 80) return Colors.greenAccent;
      if (score >= 60) return Colors.orangeAccent;
      return Colors.redAccent;
    }

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
              const SizedBox(height: 16),

              // ===== SUMMARY BAR =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scoreColor(overallScore as int).withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _reportStat('Exercises', '${history.length}', Colors.blueAccent),
                    _reportStat('Total Reps', '$totalReps', Colors.white),
                    _reportStat('Good', '$totalGood', Colors.greenAccent),
                    _reportStat('Bad', '$totalBad', Colors.redAccent),
                    _reportStat('Score', '$overallScore%', scoreColor(overallScore as int)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== EXERCISE LIST =====
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
                          final goodReps = item['good_reps'] ?? 0;
                          final badReps = item['bad_reps'] ?? 0;
                          final formScore = item['form_score'] ?? 100;
                          final mistakes = List<String>.from(item['top_mistakes'] ?? []);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Exercise name + total reps
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name.toUpperCase().replaceAll('_', ' '),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
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
                                const SizedBox(height: 10),

                                // Good/Bad reps + Form score
                                Row(
                                  children: [
                                    _miniTag('✅ $goodReps good', Colors.greenAccent),
                                    const SizedBox(width: 8),
                                    _miniTag('❌ $badReps bad', Colors.redAccent),
                                    const Spacer(),
                                    Text(
                                      'Form: $formScore%',
                                      style: TextStyle(
                                        color: scoreColor(formScore as int),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                // Form score bar
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (formScore as int) / 100.0,
                                    backgroundColor: Colors.white.withValues(alpha: .1),
                                    valueColor: AlwaysStoppedAnimation(scoreColor(formScore)),
                                    minHeight: 4,
                                  ),
                                ),

                                // Mistakes
                                if (mistakes.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ...mistakes.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.orangeAccent.withValues(alpha: .7), size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            m,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: .6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
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

  Widget _reportStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
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