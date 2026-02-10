# Career Path Finder - Setup & Run Guide

A beautiful AI-powered career guidance platform for secondary school students to discover their perfect university course.

## ✨ Features Implemented

### 📱 Beautiful UI Components:
1. **Home Screen** - Modern landing page with two pathways (Resume Upload & Chat)
2. **Resume Upload Screen** - Drag-and-drop file upload with AI analysis
3. **Chat Screen** - Interactive chatbot with personalized recommendations
4. **Recommendation Screen** - Beautiful display of course recommendations
5. **Material Design 3** - Modern purple gradient theme with smooth animations

### 🎨 Design Highlights:
- Gradient backgrounds and modern cards
- Smooth animations and loading states
- Responsive layout for all screen sizes
- Intuitive user experience
- Beautiful color scheme (Deep Purple #673AB7)

## 🚀 Quick Start

### Option 1: Run on Web (Chrome/Edge) - No Setup Required ✅

```bash
cd c:\Users\User\Kitahack2026\sleepnotfound404
flutter run -d chrome
```

Or with Edge:
```bash
flutter run -d edge
```

### Option 2: Run on Windows Desktop (Requires Developer Mode)

Before running, enable Developer Mode on Windows:
1. Press `Win + I` to open Settings
2. Go to **Privacy & security** → **For developers**
3. Toggle **Developer Mode** ON

Then run:
```bash
flutter run
```

### Option 3: Run on Android Emulator
```bash
flutter run -d <emulator-name>
```

## 📋 Project Structure

```
lib/
├── main.dart                              # App entry point
├── features/
│   ├── home/
│   │   └── home_screen.dart              # Home/landing page
│   ├── career_analysis/
│   │   ├── upload_screen.dart            # Resume upload UI
│   │   └── recommendation_screen.dart    # Results display
│   ├── chat_guidance/
│   │   └── chat_screen.dart              # Chat with bot UI
├── services/
│   └── gemini_service.dart               # Gemini API integration
```

## 🎯 How the App Works

### 1. **Home Screen**
   - Users see two main options
   - Resume Upload: Upload CV/Resume for analysis
   - Chat with Bot: Answer questions for personalized guidance

### 2. **Resume Upload Path**
   - Click to upload PDF/TXT/DOC/DOCX
   - AI analyzes the resume
   - Get personalized course recommendations

### 3. **Chat Path**
   - Interactive conversation with AI bot
   - Quick suggestion pills for easy input
   - Real-time responses about suitable courses
   - Get recommendations for Malaysian universities

## 🎨 Color Scheme

Primary Color: **#673AB7** (Deep Purple)
- Used for main buttons, headers, and accents
- Gradient variants for modern look
- Accessibility-friendly with proper contrast

## ⚙️ Configuration

### Required `.env` File
Create a `.env` file in the root directory:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

### Firebase Setup
The app uses Firebase. Ensure you've run:
```bash
flutterfire configure
```

## 📦 Dependencies

Key packages used:
- `firebase_core` - Firebase backend
- `google_generative_ai` - Gemini AI integration
- `file_picker` - Resume file upload
- `flutter_spinkit` - Loading animations
- `flutter_dotenv` - Environment variables

## 🔧 Building & Testing

### Get Dependencies
```bash
flutter pub get
```

### Build Web Version
```bash
flutter build web
```

### Run Tests
```bash
flutter test
```

## 📱 Mobile Deployment

### Android
```bash
flutter build apk
# or
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## 🐛 Troubleshooting

### Chrome not launching?
```bash
flutter run -d chrome --no-fast-start
```

### Port already in use?
```bash
flutter run -d chrome --web-port 8080
```

### Dependencies not installing?
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 🌟 UI Improvements Made

✅ Modern Material Design 3
✅ Beautiful gradient backgrounds
✅ Smooth loading animations (SpinKit)
✅ Responsive card-based layouts
✅ Clear visual hierarchy
✅ User-friendly error handling
✅ Quick action suggestion pills
✅ Progress indicators for AI analysis
✅ Professional color scheme
✅ Accessibility considerations

## 📝 Next Steps

1. **Test on Web**: `flutter run -d chrome`
2. **Check Firebase**: Verify Firebase is properly configured
3. **Add Content**: Customize greeting messages and recommendations
4. **Deploy**: Build APK/Web for distribution

## 💡 Tips for Users

- The app works best with recent browser versions
- Mobile experience is optimized for phones
- All UI components are touch-friendly
- Loading states show progress clearly
- Recommendations are sorted by match percentage

## 🤝 Support

For issues or questions:
1. Check the Flutter documentation
2. Verify your Gemini API key is correct
3. Ensure Firebase is properly initialized
4. Clear cache: `flutter clean` if experiencing issues

---

**Enjoy your beautiful new Career Path Finder app! 🎓✨**
