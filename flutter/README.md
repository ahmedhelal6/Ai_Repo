# AI Fitness Coach - Mobile App 📱

The frontend of the AI Fitness Coach ecosystem, built with Flutter. This application handles real-time pose extraction, UI overlays, and maintains a persistent connection with the AI Backend for advanced movement analysis.

---

## ✨ Mobile Features

- 🚀 Real-Time Pose Extraction: Leverages Google ML Kit for high-speed, on-device skeletal landmark detection (33 points).
- 💎 Premium UI/UX:
    - Glassmorphism Design: Modern, semi-transparent overlays for pause menus and reports.
    - Dynamic HUD: Real-time heads-up display showing Reps, Exercise Name, and Stage.
    - Interactive Charts: Visual progress tracking using fl_chart.
- 🔌 WebSocket Integration: Low-latency, full-duplex communication to stream landmark data to the Python server.
- 🔔 Smart Notifications: Local reminders for workout schedules.
- 🛠 Permission Management: Robust handling of Camera and Storage permissions.

---

## 🛠 Tech Stack (Frontend)

| Category | Technology |
| :--- | :--- |
| Framework | Flutter (https://flutter.dev/) |
| Language | Dart (https://dart.dev/) |
| AI Vision | Google ML Kit Pose Detection (https://pub.dev/packages/google_mlkit_pose_detection) |
| Networking | Dio (https://pub.dev/packages/dio) & WebSockets |
| Charts | FL Chart (https://pub.dev/packages/fl_chart) |
| Multimedia | Camera & Omni Video Player |
| Local Storage | Shared Preferences |

---

## 📂 Architecture (Flutter)

```text
lib/
├── views/                # Main UI Screens (AI Coach, Reports, Home)
├── widgets/              # Reusable UI components (Banners, Gauges)
├── models/               # Data structures for Landmarks & Workouts
├── services/             # WebSocket, API, and Notification logic
└── utils/                # Constants, Themes, and Angle Calculators
