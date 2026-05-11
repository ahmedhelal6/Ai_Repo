       # 🏋️ AI Fitness Coach

An AI-powered real-time fitness coaching system that uses **ST-GCN (Spatial-Temporal Graph Convolutional Network)** for exercise classification and **rule-based angle analysis** for repetition counting and form evaluation. The system runs as a **client-server architecture** with a Flutter mobile app and a Python FastAPI backend.

---

## 📐 System Architecture

```
┌─────────────────────────────┐         WebSocket (Binary)        ┌──────────────────────────────┐
│      Flutter Mobile App     │  ──────────────────────────────►  │     Python FastAPI Server     │
│                             │                                   │                               │
│  • Camera Capture           │         JSON Response             │  • ST-GCN Model (PyTorch)     │
│  • ML Kit Pose Detection    │  ◄──────────────────────────────  │  • Rep Counter (Angle-based)  │
│  • Real-time HUD Display    │                                   │  • Session Manager            │
│  • Workout Report UI        │                                   │  • Form Evaluation            │
└─────────────────────────────┘                                   └──────────────────────────────┘
```

---

## 🧠 Supported Exercises

| Exercise         | Mode         | Primary Joints Tracked              |
|------------------|--------------|--------------------------------------|
| Bicep Curl       | up_down_up   | Shoulder → Elbow → Wrist            |
| Squat            | down_up      | Hip → Knee → Ankle                  |
| Deadlift         | down_up      | Shoulder → Hip → Knee               |
| Shoulder Press   | up_down_up   | Hip → Shoulder → Elbow              |
| Lateral Raise    | up_down_up   | Elbow → Shoulder → Hip              |
| Push-up          | down_up      | Shoulder → Elbow → Wrist            |

---

## 1. AI Backend (Python)

### 1.1 Prerequisites

1. **Python 3.10+** (recommended via [Anaconda](https://www.anaconda.com/))
2. **PyTorch** (CPU or CUDA)
3. **pip** or **conda** package manager
4. **Trained model weights** (`best_model.pth`) — must be in the project root

### 1.2 Installation

```bash
# Clone the repository
git clone https://github.com/ahmedhelal6/Ai_Repo.git
cd Ai_Repo

# Create and activate conda environment (recommended)
conda create -n ml python=3.10 -y
conda activate ml

# Install PyTorch (CPU version — for GPU, visit https://pytorch.org)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install project dependencies
pip install fastapi uvicorn numpy mediapipe opencv-python
```

### 1.3 Running the Backend Server

```bash
# Make sure you are in the project root directory
cd Ai_Repo

# Activate the environment
conda activate ml

# Start the WebSocket API server
python api.py
```

The server will start on `http://0.0.0.0:8000`. You should see:
```
✅ ST-GCN Loaded: 4 channels, 39 joints
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

> **⚠️ Important:** The server must be running **before** launching the Flutter app. Both the phone and the PC must be connected to the **same WiFi network**.

### 1.4 Project Structure (Python)

```
Ai_Repo/
├── api.py                          # FastAPI WebSocket server (entry point)
├── app.py                          # Local camera version (standalone, for testing)
├── best_model.pth                  # Trained ST-GCN model weights
│
├── src/
│   ├── core/
│   │   └── config.py               # Global settings & paths
│   │
│   ├── pipeline/
│   │   └── realtime_pipeline.py    # Main controller — motion detection, classification, rep counting
│   │
│   ├── model/
│   │   └── stgcn.py                # ST-GCN neural network (Spatial-Temporal Graph CNN)
│   │
│   ├── pose/
│   │   ├── extractor.py            # MediaPipe wrapper — keypoint extraction & normalization
│   │   ├── joints.py               # Joint indices, class labels, skeleton edges
│   │   └── normalization.py        # Keypoint normalization logic
│   │
│   ├── counter/
│   │   ├── rep_counter.py          # Repetition counter — stage detection (up/down) with confirmation
│   │   ├── rules.py                # Per-exercise config — angles, thresholds, form checks
│   │   └── angles.py               # Angle calculation between 3 joints
│   │
│   ├── session/
│   │   └── session_manager.py      # Session state, workout history, report generation
│   │
│   └── ui/                         # OpenCV UI overlays (used in standalone app.py mode)
│
├── model_train/                    # Training scripts for ST-GCN
├── pose_landmark_model/            # MediaPipe .task model file
└── reports/                        # Saved workout reports
```

### 1.5 API Endpoints

| Endpoint                   | Type      | Description                                |
|----------------------------|-----------|--------------------------------------------|
| `ws://<IP>:8000/ws/<id>`   | WebSocket | Main communication channel                 |

**WebSocket Message Types:**

| Direction       | Format  | Content                                      |
|-----------------|---------|----------------------------------------------|
| Mobile → Server | Binary  | 132 Float32 values (33 landmarks × 4 values) |
| Mobile → Server | JSON    | `{"command": "resume" / "finish" / "restart"}` |
| Server → Mobile | JSON    | State update: exercise, reps, stage, feedback |
| Server → Mobile | JSON    | `{"type": "REPORT", "data": {...}}`           |

---

## 2. Flutter Mobile App

### 2.1 Prerequisites

1. **Flutter SDK** (3.10+)
2. **Dart SDK** (included with Flutter)
3. **Android Studio** or **VS Code** with Flutter extension
4. **Android device** (physical, connected via USB) or Android Emulator

### 2.2 Installation

```bash
# Navigate to the Flutter project directory
cd Ai_Repo/ai_fit/flutter

# Install dependencies
flutter pub get
```

### 2.3 Configuration

Before running, update the server IP address in the Flutter code to match your PC's local IP:

**File:** `lib/views/aicoachscreen.dart` (Line 12)
```dart
const String _kPythonHost = '192.168.1.12'; // ← Change to your PC's IP
```

To find your PC's IP:
```bash
# Windows
ipconfig
# Look for "IPv4 Address" under your WiFi adapter
```

### 2.4 Running the App

```bash
# Make sure you are in the Flutter project directory
cd Ai_Repo/ai_fit/flutter

# Run on connected Android device
flutter run
```

### 2.5 Flutter Dependencies

| Package                        | Purpose                              |
|--------------------------------|--------------------------------------|
| `camera`                       | Camera stream capture                |
| `google_mlkit_pose_detection`  | On-device pose detection (33 joints) |
| `web_socket_channel`           | WebSocket communication with server  |

### 2.6 Flutter Project Structure

```
ai_fit/flutter/
├── lib/
│   ├── main.dart                   # App entry point & routing
│   ├── views/
│   │   └── aicoachscreen.dart      # AI Coach screen — camera, ML Kit, WebSocket, HUD
│   ├── controllers/                # Business logic controllers
│   ├── models/                     # Data models
│   ├── services/                   # Backend services
│   ├── widgets/                    # Reusable UI components
│   └── core/                      # Theme, constants
├── assets/                         # Images & icons
├── android/                        # Android platform config
└── pubspec.yaml                    # Flutter dependencies
```

---

## 3. How It Works (Data Flow)

```
1. 📱 Camera captures frame
          │
2. 🤖 ML Kit detects 33 body landmarks on-device
          │
3. 📡 Landmarks sent as binary Float32 via WebSocket
          │
4. 🖥️ Python server receives & reconstructs landmarks
          │
5. 🧮 PoseExtractor normalizes keypoints (33 → 39 joints with angles)
          │
6. 🧠 ST-GCN classifies exercise type (if not locked)
          │
7. 📐 RepCounter tracks angles & counts reps (up/down stages)
          │
8. ✅ Form evaluation checks secondary angles for quality
          │
9. 📤 JSON response sent back: {exercise, reps, stage, feedback}
          │
10. 📱 Flutter HUD updates in real-time
```

---

## 4. Quick Start (Full Setup)

**Terminal 1 — Start the Python server:**
```bash
cd Ai_Repo
conda activate ml
python api.py
```

**Terminal 2 — Run the Flutter app:**
```bash
cd Ai_Repo/ai_fit/flutter
flutter run
```

> **📌 Checklist before running:**
> - [ ] Phone and PC on the same WiFi network
> - [ ] Correct IP address set in `aicoachscreen.dart`
> - [ ] `best_model.pth` exists in the project root
> - [ ] Python server is running and shows "Uvicorn running"
> - [ ] Phone is connected via USB with USB debugging enabled
