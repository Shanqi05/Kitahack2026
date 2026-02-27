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

