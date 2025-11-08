# MYF Connect

A Flutter application for Gujarat Methodist Camps and Methodist Youth Fellowship (MYF) community management.

[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-Enabled-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Android](https://img.shields.io/badge/Android-Supported-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com/)

---

## 📱 About

**MYF Connect** is a comprehensive community management platform designed specifically for the Gujarat Methodist community. The app facilitates seamless camp management, event organization, and Methodist Youth Fellowship (MYF) activities with sophisticated role-based access control.

### ✨ Key Features

-   🔐 **Google Sign-In Authentication** - Secure Firebase-based authentication
-   🏕️ **Camps Management** - Browse and manage Methodist camps with detailed information
-   🙋‍♂️ **MYF Management** - Organize and track Methodist Youth Fellowship activities
-   📅 **Event Management** - View upcoming events and browse past event archives
-   ⭐ **Event Rating System** - Rate past events with an intuitive 5-star rating system
-   🛡️ **Admin Dashboard** - Complete administrative control for user and content management
-   🎯 **Permission System** - Granular role-based access with camp-specific permissions

---

## 🚀 Getting Started

### ✅ Prerequisites

Before you begin, ensure you have the following tools installed on your system.

| Requirement | Version | Installation |
| :--- | :--- | :--- |
| **Dart SDK** | `^3.9.0` | [Install Dart](https://dart.dev/get-dart) |
| **Flutter SDK** | `3.19.0+` | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| **Firebase CLI** | Latest | `npm install -g firebase-tools` |
| **FlutterFire CLI** | Latest | `dart pub global activate flutterfire_cli` |
| **Git** | Any | [Install Git](https://git-scm.com/) |

**Install FlutterFire CLI (if not already installed):**
```bash
dart pub global activate flutterfire_cli
````

-----

### 📥 Installation & Setup

Follow these steps precisely to get your development environment running.

#### 1️⃣ Clone the Repository

```bash
git clone [https://github.com/SwitU7Ronald/myf_connect.git](https://github.com/SwitU7Ronald/myf_connect.git)
cd myf_connect
```

#### 2️⃣ Clean Project & Install Dependencies

```bash
flutter clean
flutter pub get
```

#### 3️⃣ Configure Firebase **(Required)**

> ⚠️ **Important:** The `android/app/google-services.json` and `lib/firebase_options.dart` files are **not** committed to Git for security. You must generate your own by following these steps.

This command will connect your local project to Firebase.

```bash
# 1. Log in to the Firebase CLI
firebase login

# 2. Run the FlutterFire configuration tool
flutterfire configure
```

**When prompted by `flutterfire configure`:**

1.  Select an existing Firebase project or create a new one.
2.  When asked for platforms, select **`android`**.
3.  The tool will automatically generate:
      * `android/app/google-services.json`
      * `lib/firebase_options.dart`

#### 4️⃣ Enable Firebase Services

In the [Firebase Console](https://console.firebase.google.com/) for your project:

1.  Go to **Authentication** → **Sign-in method** → Enable **Google**.
2.  Go to **Cloud Firestore** → **Create database** → Start in **production mode**.

#### 5️⃣ Run the Application

```bash
flutter run
```

-----

## 📂 Project Structure

This project follows a feature-driven directory structure.

```
lib/
├── app/                  # App-level config (router, theme)
│   ├── app_router.dart
│   └── theme.dart
├── models/               # Data models (app_user.dart, event.dart, etc.)
│   ├── app_user.dart
│   ├── district_data.dart
│   ├── event.dart
│   └── rating.dart
├── pages/                # All UI screens/pages
│   ├── admin/            # Admin dashboard pages
│   ├── auth/             # Welcome, Sign-up pages
│   ├── camps/            # Camps list and detail pages
│   ├── home/             # Main menu, profile, team pages
│   └── myfs/             # MYF list and detail pages
├── services/             # Business logic (auth_service.dart, etc.)
│   ├── auth_service.dart
│   ├── cleanup_service.dart
│   └── user_service.dart
├── utils/                # Helper functions (responsive_utils.dart)
│   └── responsive_utils.dart
├── widgets/              # Reusable UI components
│   ├── cards.dart
│   ├── date_picker_field.dart
│   └── ...
├── main.dart             # App entry point
└── firebase_options.dart # Firebase config (auto-generated)

assets/
└── team/                 # Team member images
```

-----

## 📦 Core Dependencies

| Package | Purpose |
| :--- | :--- |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Cloud database |
| `google_sign_in` | Google login provider |
| `provider` | State management |
| `intl` | Date & number formatting |

-----

## 👥 User Roles & Permissions

| Role | Capabilities |
| :--- | :--- |
| **General User** | • Sign in with Google<br>• Browse camps and MYF groups<br>• View upcoming & past events<br>• Rate past events |
| **Admin** | • All user capabilities<br>• Full user management<br>• Create/edit/delete all camps & events<br>• Assign permissions<br>• Access admin dashboard |

-----

## 🛠️ Development Commands

| Command | Description |
| :--- | :--- |
| `flutter run` | Run the app in debug mode. |
| `flutter build apk --release` | Build a release APK. |
| `flutter build appbundle --release` | Build a release App Bundle for Google Play. |
| `flutter test` | Run all unit & widget tests. |
| `flutter analyze` | Analyze the project for errors & style. |

-----

## 🔐 Firebase Collections

| Collection | Description |
| :--- | :--- |
| `users` | User profiles, roles, and camp-specific permissions |
| `camps` | Methodist camp registry with details |
| `events` | Camp events (upcoming & past) with venue info |
| `myf` | MYF activity groups and membership |
| `ratings` | User ratings for past events |

-----

## 📱 Supported Platforms

  - ✅ **Android** (Fully supported)
  - ❌ **iOS** (Not supported at this time)
  - ❌ **Web** (Not supported at this time)

-----

## 👨‍💻 Author

**Kshitij Parmar**
*Developer & Maintainer*

  - GitHub: [@SwitU7Ronald](https://github.com/SwitU7Ronald)
  - LinkedIn: [kshitij-parmar](https://www.linkedin.com/in/kshitij-parmar)

-----

## 🙏 Acknowledgments

  - Gujarat Methodist Community
  - Methodist Youth Fellowship (MYF)
  - [Flutter Team](https://flutter.dev)
  - [Firebase Team](https://firebase.google.com)

-----

## 📞 Support

For support, please open an issue or start a discussion in the repository.

  - 🐛 **Report a Bug:** [GitHub Issues](https://www.google.com/search?q=https://github.com/SwitU7Ronald/myf_connect/issues)
  - 💬 **Ask a Question:** [GitHub Discussions](https://www.google.com/search?q=https://github.com/SwitU7Ronald/myf_connect/discussions)

-----

**Made with ❤️ for the Gujarat Methodist Community**

⭐ Star this repo if you find it helpful\!

