import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:methodist_connect/pages/auth/welcome_page.dart';
import 'pages/home/main_menu_page.dart';

import 'app/firebase_options.dart';
import 'app/app_router.dart';
import 'app/theme.dart';
import 'services/auth_service.dart';

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
          // main.dart (replace the StreamBuilder builder body)
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final user = snapshot.data;
            if (user == null) {
              // Show Welcome directly; do not wrap a Navigator here
              return const WelcomePage();
            }
            return const MainMenuPage();
          }
      ),
    );
  }
}
