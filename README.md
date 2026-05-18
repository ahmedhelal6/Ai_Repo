# 🏋️‍♂️ AI Fitness Coach 🤖

An end-to-end, real-time AI fitness coaching ecosystem. This project combines a high-performance **Flutter** mobile application with a **FastAPI** AI engine powered by Spatial-Temporal Graph Convolutional Networks (ST-GCN) and a robust **.NET** backend.

It doesn't just count reps; it understands human motion, provides real-time form correction, and generates comprehensive performance reports.

---

# 🌟 Ecosystem Architecture

The project is split into three main interconnected modules:

## 📱 1. Mobile App (Flutter)

- **Framework:** Flutter & Dart
- **AI Vision:** Google ML Kit Pose Detection
- **Communication:** WebSockets + REST API
- **Features:**
  - Real-time camera feed
  - Dynamic overlays
  - Live HUD
  - Workout history
  - User profile management

### Mobile Pipeline

```text
Camera → ML Kit → Landmark Extraction → WebSocket
```

---

## 🧠 2. AI Engine (Python)

- **Framework:** FastAPI / WebSockets
- **Deep Learning Model:** ST-GCN (PyTorch)
- **Form Analysis:** LSTM (PyTorch)
- **Physics Engine:** Joint-angle analysis + heuristic rules
- **Privacy First:** Only numerical landmarks are streamed

### AI Processing Flow

```text
Pose Landmarks
      ↓
ST-GCN Classification
      ↓
LSTM Form Analysis
      ↓
Physics Rule Engine
      ↓
Rep Counting + Feedback
```

### Key AI Advantages

| Feature | Benefit |
|---|---|
| ST-GCN | Temporal skeletal motion understanding |
| Rule Engine | Accurate deterministic rep counting |
| WebSockets | Ultra-low latency communication |

---

## ⚙️ 3. Core Backend (.NET)

- **Framework:** .NET (C#)
- **Responsibilities:**
  - Authentication
  - User management
  - Workout reports
  - Diet plans
  - Secure database operations

---

# 🚀 Key Features

- 🤖 **Automated Exercise Recognition**
- ⚙️ **Physics-Based Rep Counting**
- 📢 **Real-Time Form Correction**
- 📊 **Detailed Performance Reports**
- ⏱️ **Hands-Free Workout Experience**
- 🔒 **Privacy-Focused Architecture**
- ⚡ **Ultra-Low Latency (<50ms)**

---

# 🎯 AI Performance

| Component | Technology | Accuracy |
|---|---|---|
| Rep Counting | Trigonometric Rules | 100% |
| Exercise Detection | ST-GCN | ~95.6% |
| System Latency | WebSockets + ML Kit | <50ms |

---

# 📋 Supported Exercises

| Exercise | Tracked Landmarks | Goal |
|---|---|---|
| Squat | Hip, Knee, Ankle | Proper depth & posture |
| Push-up | Shoulder, Elbow, Wrist | Full range of motion |
| Bicep Curl | Shoulder, Elbow, Wrist | Controlled contraction |
| Deadlift | Shoulder, Hip, Knee | Neutral spine |
| Shoulder Press | Shoulder, Elbow, Wrist | Full extension |
| Lateral Raise | Shoulder, Elbow | Shoulder-level alignment |

---

# 🏗️ System Architecture

```text
User Movement
      ↓
Flutter Camera Stream
      ↓
Google ML Kit Pose Detection
      ↓
Landmark Serialization
(X, Y, Z coordinates)
      ↓
WebSocket Streaming
      ↓
FastAPI AI Engine
      ↓
├── ST-GCN → Exercise Classification
├── LSTM → Form Assessment
└── Physics Engine → Rep Counter
      ↓
Live Feedback Returned
      ↓
Flutter HUD Updates
      ↓
.NET Backend Storage
```

---

# 📂 Project Structure

```text
Ai_Repo/
├── flutter/
│   ├── lib/
│   │   ├── views/
│   │   ├── services/
│   │   └── models/
│   └── pubspec.yaml
│
├── AI/
│   ├── api.py
│   ├── src/
│   ├── best_model.pth
│   └── requirements.txt
│
└── backend/
    ├── Ai Fitness Coach/
    └── Ai Fitness Coach.slnx
```

---

# 🛠️ Installation & Setup

## 1️⃣ Run the .NET Backend

```bash
cd backend
dotnet run
```

---

## 2️⃣ Run the AI Engine

```bash
cd AI

python -m venv venv

# Windows
venv\Scripts\activate

# Linux / Mac
source venv/bin/activate

pip install -r requirements.txt

python api.py
```

AI server endpoint:

```text
ws://0.0.0.0:8000/ws/flutter_user
```

---

## 3️⃣ Run the Flutter Application

```bash
cd flutter

flutter pub get

flutter run
```

> Update `_kPythonHost` inside:
>
> `flutter/lib/views/aicoachscreen.dart`
>
> to match your local machine IP when using a physical device.

---

# 🔒 Privacy & Security

- No video frames are transmitted
- Only skeletal coordinates are streamed
- Lightweight encrypted communication
- Designed for scalable real-time inference

---

# 🚀 Future Improvements

- Transformer-based form analysis
- Personalized body calibration
- Voice coaching assistant
- Fatigue & failure prediction
- Cloud deployment with Kubernetes
- Advanced analytics dashboard

---

# ⭐ Tech Stack

| Layer | Technologies |
|---|---|
| Mobile | Flutter, Dart, ML Kit |
| AI | PyTorch, FastAPI, ST-GCN, LSTM |
| Backend | .NET, C# |
| Communication | WebSockets, REST API |

---

# 📜 License

This project is intended for educational and research purposes.
