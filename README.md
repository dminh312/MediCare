# 🏥 MediCare+

MediCare+ is a comprehensive health and medical management application built with Flutter. It helps users track their daily health metrics and provides a seamless way to manage medications, monitor progress, and access customer support.

## ✨ Key Features

- **❤️ Health Tracking:** Integrated with Google Health Connect for accurate tracking of core health metrics such as daily step count, heart rate, and sleep analysis.
- **💊 Medication Management:** Efficiently manage daily medication lists with automated reminders and an intuitive logging system.
- **🔒 App Security:** Protect personal health data with secure app-lock functionality (PIN lock).
- **🎛️ Admin Terminal:** Built-in staff and role management for administrative operations, you can follow this repo to build your own admin terminal (https://github.com/dminh312/MediCare-_AdminDashboard).
- **💬 Customer Support:** Direct in-app support chat functionality to assist users whenever they need help.
- **☁️ Cloud Sync:** Powered by Firebase for real-time data sync, authentication, and secure remote configurations.

## 🛠 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) & Dart
- **Backend & Database:** [Firebase](https://firebase.google.com/)
- **Health Data:** Google Health Connect
- **UI Design:** Kinetic Precision Design System

## 🚀 Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- Flutter SDK (latest version)
- CocoaPods (for iOS)
- Android Studio / Xcode

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/dminhdiahuong/MediCare.git
   ```
2. Install dependencies
   ```sh
   flutter pub get
   ```
3. Set up Firebase
   - Ensure the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly configured in their respective directories.
4. Run the app
   ```sh
   flutter run
   ```

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
