# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AI Math Helper is a Flutter mobile application with Firebase authentication and Google Sign-In integration. The app includes math input functionality with document scanning capabilities and handwriting recognition using a custom scribble library.

## Development Commands

### Build and Run
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version

### Code Generation
- `dart run build_runner build` - Generate code for Riverpod, Freezed, and JSON serialization
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Testing and Analysis
- `flutter test` - Run widget tests
- `flutter analyze` - Run static analysis
- `dart run custom_lint` - Run custom lints including Riverpod lints

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Notebook Feature
- **Notebooks View**: Access via navigation tab (Books icon)
- **Create Notebooks**: Organize math problems by subject/topic
- **Import Problems**: Use camera scanner or gallery images
- **Problem Management**: Track status (unsolved, in progress, solved, needs help)
- **AI Integration**: Ready for feedback and hints system
- **Permissions**: Camera and storage permissions are properly configured for document scanning

## Architecture

### State Management
- Uses **Riverpod** with code generation for state management
- Providers are generated using `@riverpod` annotations
- State classes use **Freezed** for immutable data classes

### Data Layer Structure
```
lib/data/
├── user/          # Authentication data and models
├── home/          # Home screen data and models  
├── main/          # Main app data and models
```

### View Layer Structure
```
lib/view/
├── home/          # Home screen UI
├── loginPage/     # Authentication UI
├── math_input/    # Math input screen with handwriting
├── profile/       # User profile modal and screen
```

### Key Dependencies
- **firebase_core** + **firebase_auth** - Authentication
- **google_sign_in** - Google OAuth
- **flutter_riverpod** + **riverpod_annotation** - State management
- **freezed** + **json_annotation** - Data classes and serialization
- **scribble** (custom fork) - Handwriting/drawing input
- **flutter_doc_scanner** - Document scanning
- **material3_layout** - Material 3 layout components

### Firebase Configuration
- Firebase is initialized in `main.dart` using `DefaultFirebaseOptions.currentPlatform`
- Authentication state is managed in `lib/data/user/model/auth_model.dart`
- Uses Google Sign-In as the primary authentication method

### Code Generation Files
Generated files (`.g.dart`, `.freezed.dart`) are committed to the repository and should be regenerated when data models change.

## Development Notes

- The app uses Material 3 design with system theme mode support
- Custom scribble library is loaded from a forked GitHub repository
- Firebase configuration files are included for Android (`google-services.json`) and iOS (`GoogleService-Info.plist`)
- Document scanning functionality is integrated for math problem capture