# AI Fitness Coach 🏋️‍♂️

An end-to-end, real-time AI fitness coaching ecosystem. This project combines a high-performance **Flutter** mobile application with a **FastAPI** backend powered by **Spatial-Temporal Graph Convolutional Networks (ST-GCN)**.

It doesn't just count reps; it understands human motion, provides real-time form correction, and generates comprehensive performance reports.

---

## 🚀 Key Features

- **🤖 Automated AI Classification**: Uses ST-GCN to automatically identify the exercise you are performing without manual selection.
- **⏱️ Hands-Free Experience**: Intelligent countdowns and motion-triggered starts allow you to focus entirely on your workout.
- **📢 Real-Time Form Correction**: Instant feedback banners guide you to maintain proper posture and technique.
- **📊 Dynamic Workout Reports**: Get a detailed breakdown of your performance, including total reps, accuracy, and form consistency.
- **🧠 Intelligent Session Control**: Automatically pauses the session if you stop moving, and provides easy options to Resume or Restart.
- **⚡ Low-Latency Performance**: Optimized for mobile devices with high-speed server-side inference.
- **🔒 Privacy-First Design**: Video processing happens on-device; only numerical landmark data is sent to the server. No video is ever stored or transmitted.
- **📈 Comprehensive Exercise Library**: Native support for Squats, Push-ups, Bicep Curls, Deadlifts, Shoulder Press, and Lateral Raises.
- **🔊 Visual & Textual Guidance**: Immediate on-screen alerts for form correction and performance encouragement.
- **⚙️ Physics-Based Counting**: Uses trigonometric rules and joint-angle analysis for 100% accurate repetition tracking.

---

## 🌟 The Experience (User Journey)

1.  **Smart Detection**: As soon as you stand in front of the camera, the app identifies your presence.
2.  **Countdown & Prep**: Once motion is detected, a large, premium countdown appears (3... 2... 1...) to give you time to get into position.
3.  **Real-Time Coaching**: During your set, the app shows:
    - **Live Rep Counter**: Updates instantly as you complete movements.
    - **Stage Tracking**: Shows if you are currently in the "UP" or "DOWN" phase.
    - **Form Feedback**: Dynamic banners warn you about form issues (e.g., "Keep elbows tucked").
4.  **Intelligent Pause**: If you stop moving for 5 seconds, the app automatically pauses and shows a decision menu (Resume / Restart / Finish).
5.  **Workout Report**: After finishing, a sleek overlay presents your total reps, accuracy, and a breakdown of each exercise performed.

---

## 📱 Frontend Deep Dive (Flutter)

The mobile app is built for speed and responsiveness:
-   **Pose Extraction**: Uses **Google ML Kit** to extract 33 skeletal landmarks directly on the device.
-   **Throttled Transmission**: To ensure stability on all network types, landmarks are sent to the server at a steady.
-   **Z-Axis Normalization**: Custom logic scales the Z-depth relative to frame width to ensure coordinate consistency across different devices.
-   **Premium UI**:
    -   **Glassmorphism Overlays**: Modern, semi-transparent menus for Pause and Reports.
    -   **Dynamic HUD**: A specialized bottom bar that tracks Exercise Name, Reps, and Stage.

---

## ⚙️ Backend Deep Dive (FastAPI & AI)

The server acts as the "Brain" of the system:
-   **State Machine Pipeline**: Manages the session state (`IDLE`, `COUNTDOWN`, `BUFFERING`, `ACTIVE`).
-   **ST-GCN Classification**: A Deep Learning model that analyzes a **30-frame sequence** of movement. It doesn't just look at one frame; it looks at the *timing* and *spatial relationship* of your joints over time.
-   **Rule Engine (`rules.py`)**:
    -   Calculates precise angles (e.g., Elbow angle for Bicep Curls, Hip angle for Squats).
    -   Uses thresholds and "Stage Logic" to ensure a rep is only counted if the full range of motion is achieved.
-   **Performance Optimization**: Implements **Inference Skipping** (running the heavy AI model only once every 10 frames) while keeping the rule-engine running every frame for instant counting.

---

## 📂 Project Architecture

```text
├── ai_fit/flutter/         # Full Flutter project
│   └── lib/views/          # AI Coach Screen & UI Logic
├── src/
│   ├── pipeline/           # RealtimePipeline (State Management)
│   ├── counter/            # RepCounter & ExerciseRules (Math & Logic)
│   └── models/             # SimpleSTGCN PyTorch Definition
├── api.py                  # WebSocket Server (The Bridge)
├── best_model.pth          # Trained ST-GCN Weights
└── README.md               # You are here!
```

---

## 🚀 Installation & Setup

### 1. Server Setup (Python)
1.  **Install dependencies**: `pip install -r requirements.txt`
2.  **Run the server**: `python api.py`
3.  **Local IP**: Find your PC's IP address (e.g., `192.168.1.5`).

### 2. Mobile Setup (Flutter)
1.  **Configure IP**: Update `_kPythonHost` in `lib/views/aicoachscreen.dart`.
2.  **Install & Run**: `flutter pub get` then `flutter run`.

---

## 📋 Supported Exercises

| Exercise | Primary Landmarks | Goal |
| :--- | :--- | :--- |
| **Squat** | Hip, Knee, Ankle | Deep sit, full stand |
| **Bicep Curl** | Shoulder, Elbow, Wrist | Full contraction, no swing |
| **Deadlift** | Shoulder, Hip, Knee | Straight back, full lockout |
| **Push-up** | Shoulder, Elbow, Wrist | Chest to ground, full lock |

---

## 📄 License
Licensed under the MIT License. Built with ❤️ for the AI Fitness Community.
