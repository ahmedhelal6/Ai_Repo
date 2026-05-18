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
---
## Flutter Installation

AI Fitness Coach can be installed and run as a Flutter mobile application. The application supports Android development using Flutter and can be tested on either an Android emulator or a physical Android device.

```bash
git clone https://github.com/ahmedhelal6/Ai_Repo.git
cd Ai_Repo/flutter
flutter pub get
flutter run
2.1.2 Running the Development Version
Prerequisites
Flutter SDK
Dart SDK
Android Studio or Visual Studio Code
Android Emulator or physical Android device
Steps
Clone the Flutter repository.
Navigate to the project directory.
Install the required dependencies using:
flutter pub get
Run the application using:flutter run


Flutter Packages
  permission_handler: ^11.3.1
  path_provider: ^2.1.2
  omni_video_player: ^3.9.4
  fl_chart: ^0.70.0
  image_picker: ^1.2.1
  shared_preferences: ^2.5.5
  file_selector: ^1.1.0
  dio: ^5.9.2
  flutter_staggered_grid_view: ^0.7.0
  cupertino_icons: ^1.0.8
  # AI Coach
  camera: ^0.11.1
  camera_android: ^0.10.10
  google_mlkit_pose_detection: ^0.12.0
  web_socket_channel: ^3.0.1
