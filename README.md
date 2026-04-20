# IAMS - Integrated Academic Management System

IAMS is a professional, modular SaaS-style academic platform built with Flutter and PostgreSQL. It provides a highly secure and synchronized experience for students, faculty, and coordinators, featuring a unique hybrid data model that balances official college records with private personal organization.

## 🚀 Key Features

### 🛠️ Hybrid Data Architecture
*   **Organizational Data (PostgreSQL)**: Official courses, timetable instances, assignments, and attendance records are fetched from a remote server (currently configured for `localhost:5000`). This data is read-only for students to ensure institutional integrity.
*   **Personal Data (LocalStorage)**: Users can create private courses (e.g., "Self-Study", "Gym"), manage a personal timetable, and track to-do lists. This data is stored exclusively on the device using `SharedPreferences`.
*   **Per-Account Isolation**: Local data is prefixed with a unique Student ID, allowing multiple users to share a single device without data bleed.

### 🔐 Secure Authentication & Session Sync
*   **UUID Sessions**: Upon login, a unique session token is generated and synchronized between the mobile device and the PostgreSQL database.
*   **Persistent Auto-Login**: The app automatically validates the local session against the server on launch, allowing users to bypass the login screen securely.
*   **Diagnostic Sync**: Real-time error handling with pinpointed popups (e.g., "Connection Refused at localhost") to help troubleshoot database availability.

### 🎓 Academic Management
*   **Smart Timetable**: A date-wise weekly schedule featuring 1:1 finger-follow relocation. Official institution classes are protected, while personal study slots allow manual attendance toggling.
*   **Attendance Deep-Dive**: Chronological audit trails for every course. Differentiates between "Official Classes" (College-marked) and "Personal Study Hours" (Student-marked).
*   **Performance Analytics**: Automated Weighted GPA calculation based on PostgreSQL registration data (`internal` and `mid_term` marks).
*   **Role-Based UI**: Dynamic navigation bars and side-balls that adapt based on the user's role (Student, Faculty, or Event Coordinator).

### 📅 Operational Portals
*   **Event Coordinator**: Dedicated dashboard to create campus events, monitor registration trends (Engagement Analytics), and manage participant lists.
*   **Faculty**: Specialized tools to post assignments, extend deadlines, and broadcast campus-wide notices.

---

## 🛠️ Requirements

*   **Flutter SDK**: `^3.41.6` (Stable Channel)
*   **Database**: PostgreSQL 15+ (Running on port `5000` for default configuration)
*   **Backend**: Ensure your PostgreSQL server matches the schema defined in `db_schemas.txt`.

---

## 🏗️ Executing Instructions

1.  **Configure PostgreSQL**:
    Ensure your database is running and accessible at `localhost:5000` (or `10.0.2.2:5000` for Android Emulators). Apply the schemas from `db_schemas.txt`.

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

---

## ⚠️ Important Considerations for Development

1.  **Localhost Connectivity**: If testing on a physical Android device, change the database host in `lib/services/database_service.dart` to your machine's local network IP.
2.  **Schema Sync**: Any changes to the PostgreSQL `registrations` or `timetable` tables must be reflected in the `AcademicController` mapping logic.
3.  **Privacy**: Personal study hours and local courses are never transmitted to the PostgreSQL server.

---

## 📁 Project Structure

```text
lib/
├── controllers/    # Unified State Management (AcademicController)
├── services/       # Database & API Connections (DatabaseService)
├── screens/        # Feature-based UI modules (Attendance, Faculty, Events)
├── theme/          # SaaS Blue/Indigo Design System
└── widgets/        # High-tech UI Components (Smart Watch Slider)
```
