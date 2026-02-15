# Malaysian Education Navigator

A Flutter-based web platform designed to help Malaysian students navigate their post-spm education journey using AI-driven analysis and personalized recommendations.

## 🚀 Getting Started

If you have just cloned this repository, follow these steps to set up the environment and run the project.

### 1. Prerequisites
Ensure you have the following installed:
- **Flutter SDK** (Channel stable)
- **Node.js & npm** (Required for Firebase CLI)
- **Dart SDK**

### 2. Environment Configuration
This project uses sensitive API keys that are not included in the repository. You must configure them manually.

#### A. Gemini AI API Key
1. Navigate to `lib/core/constants/`.
2. Duplicate `secrets.example.dart` and rename it to `secrets.dart`.
3. Open `secrets.dart` and paste your Gemini API Key.
   ```dart
   class Secrets {
     static const String geminiApiKey = "YOUR_ACTUAL_API_KEY_HERE";
   }
   ```
   *Get your key from [Google AI Studio](https://aistudio.google.com/app/apikey).*

#### B. Firebase Configuration
1. Install Firebase tools globally (if not compliant):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
2. Log in to Firebase:
   ```bash
   firebase login
   ```
3. Configure the app with your Firebase project:
   ```bash
   dart pub global run flutterfire_cli:flutterfire configure /
   flutterfire configure
   ```
   - Follow the prompts to select your project and platforms (Web is required).
   - This command will automatically generate `lib/firebase_options.dart`.

### 3. Installation
Install the project dependencies:
```bash
flutter pub get
```

### 4. Running the App
Run the application in Chrome (current target platform):
```bash
flutter run -d chrome
```

---

## 🛠 Project Structure
- `lib/core`: Shared utilities, constants, and services (Auth, Gemini).
- `lib/features/wizard`: The profile setup wizard (Identity, Academic, Financial, Talents).
- `lib/features/dashboard`: The main application shell containing Analysis, AI Chat, etc.
- `lib/features/auth`: Login and Registration screens.

## 🔑 Key Features
- **Guest Mode**: Try the app without logging in (Firebase Auth Anonymous).
- **AI Analysis**: Scans result slips and extracts grades (Gemini Vision).
- **AI Chat Advisor**: Ask questions about scholarships and universities.
- **Glassmorphism UI**: Modern, clean interface designed for web.

## ⚠️ Troubleshooting
- **Firebase Error**: If you see errors about "DefaultFirebaseOptions", ensure you ran `flutterfire configure`.
- **Gemini Error**: If AI features fail, check if `lib/core/constants/secrets.dart` exists and has a valid key.
