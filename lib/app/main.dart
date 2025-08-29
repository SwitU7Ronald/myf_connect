import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/home/main_menu_page.dart';

import './firebase_options.dart';
import 'app_router.dart';
import 'theme.dart';
import '../services/auth_service.dart';

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
          if (snapshot.connectionState != ConnectionState.active) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Something went wrong')),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Navigator(
              initialRoute: AppRoutes.credit,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          } else {
            return const MainMenuPage();
          }
        },
      ),
    );
  }
}
