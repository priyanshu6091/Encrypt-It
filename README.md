# mad_mini_project

A cross-platform Flutter application for securely storing and managing encrypted text notes.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Build & Run](#build--run)
- [Platform-specific Notes](#platform-specific-notes)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview

**mad_mini_project** is a Flutter-based application designed to work seamlessly across Android, iOS, macOS, Windows, Linux, and Web. It allows users to create, encrypt, and manage text notes securely.

---

## Features

- Create, edit, and delete encrypted text notes.
- Cross-platform support: Android, iOS, macOS, Windows, Linux, Web.
- Modern Flutter architecture.
- Firebase Analytics integration (Android).
- Responsive UI for web and desktop.
- Platform-specific launch screens and icons.

---

## Screenshots

<img width="507" alt="image" src="https://github.com/user-attachments/assets/df302ebc-d171-427a-b776-2759f28a4ec5" />
<img width="511" alt="image" src="https://github.com/user-attachments/assets/f47da718-493c-437a-a69f-056beb0a314e" />
<img width="508" alt="image" src="https://github.com/user-attachments/assets/eb38383b-75d5-426b-9ae2-210205b72f2b" />
<img width="507" alt="image" src="https://github.com/user-attachments/assets/84ae0b59-be4f-4f1c-9e65-ce41094e560c" />




## Project Structure

```
mad_mini_project/
├── android/           # Android native project files
├── ios/               # iOS native project files (Xcode)
├── lib/               # Dart source code (main app logic)
│   └── models/        # Dart data models (e.g., encrypted_text.dart)
├── macos/             # macOS native project files (Xcode)
├── web/               # Web-specific files (index.html, manifest.json)
├── windows/           # Windows native project files
├── analysis_options.yaml # Dart analysis/lint rules
├── pubspec.yaml       # Flutter dependencies and assets
└── README.md          # Project documentation
```

### Key Files

- **lib/main.dart**: Main entry point for the Flutter app.
- **lib/models/encrypted_text.dart**: Model for encrypted text notes.
- **web/index.html**: Web app entry point.
- **web/manifest.json**: Web app manifest for PWA support.
- **android/app/build.gradle**: Android build configuration.
- **ios/Runner.xcodeproj/**: iOS/macOS Xcode project files.
- **macos/Runner.xcodeproj/**: macOS Xcode project files.
- **windows/runner/**: Windows runner and resource files.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Platform-specific requirements:
  - Android: Android Studio, Android SDK
  - iOS/macOS: Xcode
  - Windows: Visual Studio (with Desktop development workload)
  - Web: Any modern browser

### Installation

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd mad_mini_project
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

---

## Build & Run

### Android

```sh
flutter run -d android
```

### iOS

```sh
flutter run -d ios
```

### macOS

```sh
flutter run -d macos
```

### Windows

```sh
flutter run -d windows
```

### Web

```sh
flutter run -d chrome
```

---

## Platform-specific Notes

### Android

- Firebase Analytics is integrated via `build.gradle`.
- App icons and splash screens are managed in `android/app/src/main/res/`.

### iOS/macOS

- Xcode project files are in `ios/` and `macos/`.
- Info.plist and entitlements are configured for app permissions and sandboxing.
- Launch screens and icons are managed in `Assets.xcassets`.

### Web

- PWA support via `manifest.json`.
- Icons and meta tags are set in `web/index.html`.

### Windows

- App icon and metadata are set in `windows/runner/Runner.rc` and `resource.h`.

---

## Dependencies

- [Flutter](https://flutter.dev/)
- [Firebase Analytics (Android)](https://firebase.google.com/docs/analytics)
- Other dependencies as listed in `pubspec.yaml`.

---

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Create a new Pull Request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
