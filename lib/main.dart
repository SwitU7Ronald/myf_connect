// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:methodist_connect/pages/auth/welcome_page.dart';
import 'pages/home/main_menu_page.dart';

import 'app/firebase_options.dart';
import 'app/app_router.dart';
import 'app/theme.dart';
import 'services/auth_service.dart';

// NEW imports
import 'services/user_service.dart';
import 'models/app_user.dart';
import 'pages/auth/signup_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MethodistConnectApp());
}

class MethodistConnectApp extends StatefulWidget {
  const MethodistConnectApp({super.key});

  @override
  State<MethodistConnectApp> createState() => _MethodistConnectAppState();
}

class _MethodistConnectAppState extends State<MethodistConnectApp> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Methodist Connect',
      theme: MethodistTheme.themeData,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: StreamBuilder(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snapshot.data;
          if (user == null) {
            return const WelcomePage();
          }
          // Gate by profile completeness
          return FutureBuilder<AppUser?>(
            future: UserService().getUser(user.uid),
            builder: (context, fsSnap) {
              if (fsSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final appUser = fsSnap.data;
              if (appUser == null || !appUser.isProfileComplete) {
                return const SignupDetailsPage();
              }
              return const MainMenuPage();
            },
          );
        },
      ),
    );
  }
}
