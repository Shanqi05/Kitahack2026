# 🎓 EduNavigator (Career Path Finder)
**Built by Team SleepNotFound404 for KitaHack 2026**

EduNavigator is a Flutter-based web platform designed to help Malaysian students navigate their post-spm education journey using AI-driven analysis and personalized recommendations.

---

## 🛠️ Technical Implementation Overview

Our platform is built as a highly responsive web application, heavily leveraging the Google developer ecosystem to provide a seamless, intelligent user experience.

* **Frontend (UI/UX):** Built with **Flutter (Web)**.
* **Artificial Intelligence:** Integrated **Google Gemini API** (via `google_generative_ai`).
    * as AI Chat Advisor
* **Backend & Authentication:** Powered by **Firebase**.
    * *Firebase Auth*
    * *Firestore & Storage*

---

## 💡 Innovation & Challenges Faced
### The Innovation
EduNavigator uses an AI language model to provide localized academic advice. Instead of giving generic answers, the AI is able to understand the Malaysian education system—such as UPU merit, difference between Asasi and Foundation, and student budget. With this, we help students find suitable tertiary education pathways, directly supporting SDG 4 (Quality Education).

### Challenges Faced
1. **Contextualizing the AI:** Getting a general LLM to provide accurate, specific advice for Malaysian students was difficult. We had to build dynamic background prompts that automatically translate a student's specific grades and budget into a format the AI can understand and use to give relevant answers.

2. **Web-Specific Constraints:** Building a file upload system (for student resumes) specifically for a Flutter Web application required us to bypass standard mobile-only code and implement web-safe packages for file handling.

---

## 🚀 Getting Started (Local Setup)

If you have just cloned this repository, follow these steps to set up the environment and run the project.

### 1. Prerequisites
Ensure you have the following installed:
* **Flutter SDK** (Channel stable, `>=3.10.0`)
* **Node.js & npm** (Required for Firebase CLI)
* **Dart SDK**
* Google Chrome (for web debugging)

### 2. Environment Configuration
This project uses sensitive API keys that are not included in the repository. You must configure them manually.

**A. Gemini AI API Key**
1. Navigate to `lib/core/constants/`.
2. Duplicate `secrets.example.dart` and rename it to `secrets.dart`.
3. Open `secrets.dart` and paste your Gemini API Key.

```dart
class Secrets {
  static const String geminiApiKey = "YOUR_ACTUAL_API_KEY_HERE";
}
```

*(Get your key from Google AI Studio).*

**B. Firebase Configuration**
1. Install Firebase tools globally (if not compliant):
   ```terminaloutput
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. Log in to Firebase:
   ```terminaloutput
   firebase login
    ```

3. Configure the app with your Firebase project:
   ```terminaloutput
    dart pub global run flutterfire_cli:flutterfire configure
    ```
Follow the prompts to select your project and platforms (Web is required). This command will automatically generate `lib/firebase_options.dart`.

### 3. Installation
Install the project dependencies:
```terminaloutput
flutter clean
flutter pub get
```
### 4. Running the App
Run the application in Chrome (current target platform):
```terminaloutput
flutter run -d chrome
```