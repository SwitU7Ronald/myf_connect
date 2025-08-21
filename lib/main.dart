import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'theme.dart';
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
      theme: appTheme(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.welcome,
      // Optional: redirect if already logged in
      builder: (context, child) {
        return StreamBuilder(
          stream: _auth.authStateChanges,
          builder: (context, snapshot) {
            return child!;
          },
        );
      },
    );
  }
}
