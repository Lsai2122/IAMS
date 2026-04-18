# IAMS - Integrated Academic Management System

IAMS is a professional, modular SaaS-style academic platform built with Flutter. It provides a comprehensive suite of tools for students, faculty, and administrators to manage academic life seamlessly with a modern, high-performance UI.

## 🚀 Key Features

### 🛠️ Core Infrastructure
*   **Modular Architecture**: Clean, feature-based folder structure for high maintainability.
*   **Professional SaaS UI**: A sleek Indigo & Azure design with glassmorphism and Material 3 principles.
*   **Dual Navigation System**:
    *   **Main Hotbar**: Traditional bottom navigation for top-level app sections.
    *   **Smart Watch Slider**: A high-tech, relocatable, infinite-scroll semi-circle ball for quick academic actions.
*   **Dark Mode Support**: Full system-wide dark theme synchronization.

### 🎓 Academic Management (Unified Data Model)
*   **Dynamic Timetable**: A date-wise weekly schedule with 1:1 finger-follow relocation and swipe-to-edit/delete gestures.
*   **Attendance System**: Real-time attendance marking synced across Timetable, Statistics, and Course Details.
*   **Performance Analytics**: Automated CGPA calculation and weighted grade tracking.
*   **Smart To-Do List**: Task management linked directly to specific courses.
*   **Campus Events**: Multi-tab event browser with one-tap registration and personalized "My Registrations" view.
*   **Course Library**: Structured repository of materials grouped by subject and sorted by time.
*   **Course Details**: Deep-dive views for each subject including marks, attendance history, and notes.
*   **Anonymous Grievance**: Secure, ticket-based anonymous feedback system.

---

## 🛠️ Requirements

*   **Flutter SDK**: `^3.11.4` (Stable Channel recommended)
*   **Dart SDK**: Matches Flutter version
*   **Platforms**: Android, iOS, Web (Chrome), Windows, macOS, Linux.

---

## 🏗️ Executing Instructions

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/iams_app.git
    cd iams_app
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    # To run on the default device
    flutter run

    # To run on Chrome (Web)
    flutter run -d chrome
    ```

---

## ⚠️ Important Considerations for Development

1.  **State Management**: The app currently uses a centralized `AcademicController` (ChangeNotifier) for global state. This manages the shared data between the timetable, grades, and dashboard.
2.  **Data Persistence**: Current data is stored in-memory. For a production environment, integrate **Firebase**, **Supabase**, or **SQFlite** into the `AcademicController` methods.
3.  **Authentication**: The login screen is currently a UI template. You should connect the `_login` method in `login_screen.dart` to your chosen Auth provider.
4.  **Security**:
    *   Ensure any `key.properties` or sensitive API keys are added to `.gitignore` before pushing.
    *   The Anonymous Grievance system generates local Ticket IDs; these should be synced to a secure database for admin responses.
5.  **Git Protocol**: The `.gitignore` files have been optimized for Flutter development. Avoid committing the `.idea/` or `.dart_tool/` folders.

---

## 📁 Project Structure

```text
lib/
├── controllers/    # Business logic & Global state
├── screens/        # Feature-based UI modules
│   ├── attendance/ # Tracking & Statistics
│   ├── dashboard/  # Role-specific homepages
│   ├── events/     # Campus activities
│   ├── grades/     # CGPA & Performance
│   └── ...
├── theme/          # Global styling & AppTheme
└── widgets/        # Reusable UI components (Side Ball, Empty States)
```
