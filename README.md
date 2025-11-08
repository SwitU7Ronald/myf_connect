# MYF Connect

A Flutter application for Gujarat Methodist Camps and MYF (Methodist Youth Fellowship) Management.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)

## 📱 About

MYF Connect is a comprehensive community management application designed for the Gujarat Methodist community. The app facilitates camp management, event organization, and MYF activities with role-based access control.

### Key Features

- **User Authentication**: Google Sign-In integration with Firebase Authentication
- **Camps Management**: View and manage Methodist camps with upcoming and past events
- **MYF Management**: Organize and track Methodist Youth Fellowship activities
- **Event Rating**: Rate past events with a 5-star rating system
- **Admin Dashboard**: Complete administrative control for managing users, camps, and MYF activities
- **Permission System**: Role-based access control with camp-specific permissions

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.0)
- Android Studio / VS Code
- Firebase Account
- Git

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/your-username/myf_connect.git
   cd myf_connect
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add an Android app with package name: \`com.methodist.myf_connect\`
   - Download \`google-services.json\` and place it in \`android/app/\`
   - Enable Google Sign-In in Firebase Authentication

4. **Run the app**
   \`\`\`bash
   flutter run
   \`\`\`

## 📂 Project Structure

\`\`\`
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Firebase and API services
├── widgets/         # Reusable widgets
└── main.dart        # App entry point
\`\`\`

## 🔧 Configuration

### Package Name
- **Android**: \`com.methodist.myf_connect\`
- **App Name**: MYF Connect

### Dependencies

- **firebase_core**: ^4.0.0
- **firebase_auth**: ^6.0.1
- **cloud_firestore**: ^6.0.0
- **google_sign_in**: 6.3.0
- **provider**: ^6.1.5+1
- **intl**: ^0.20.2

## 📖 User Guide

### For General Users

1. **Sign Up/Sign In**: Use Google Sign-In to authenticate
2. **Browse Camps**: View all Methodist camps in the Camps tab
3. **Browse MYF**: Access MYF activities in the MYF tab
4. **View Events**: Check upcoming and past events for each camp
5. **Rate Events**: Rate past events on a 5-star scale
6. **Profile**: View and manage your profile and permissions

### For Administrators

1. **Admin Dashboard**: Access via the icon next to the profile
2. **User Management**: Approve/disapprove user permissions for specific camps
3. **Camp Management**: Create, edit, and delete camps and their events
4. **MYF Management**: Manage MYF activities and details
5. **Event Management**: Add, edit, or delete events for camps

## 🛠️ Development

### Run in Debug Mode
\`\`\`bash
flutter run
\`\`\`

### Build APK
\`\`\`bash
flutter build apk --release
\`\`\`

### Run Tests
\`\`\`bash
flutter test
\`\`\`

### Code Analysis
\`\`\`bash
flutter analyze
\`\`\`

## 🔐 Firebase Collections

- **users**: User profiles and permissions
- **camps**: Methodist camps data
- **events**: Camp events (upcoming and past)
- **myf**: MYF activities and details
- **ratings**: Event ratings by users

## 📱 Supported Platforms

- ✅ Android
- ⏳ iOS (Coming soon)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit your changes (\`git commit -m 'Add some AmazingFeature'\`)
4. Push to the branch (\`git push origin feature/AmazingFeature\`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- Gujarat Methodist Community
- Methodist Youth Fellowship
- Flutter & Firebase teams

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

## 🔗 Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Documentation](https://dart.dev/guides)

---

Made with ❤️ for the Gujarat Methodist Community
