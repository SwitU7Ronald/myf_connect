import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MethodistConnectApp());
}

class MethodistConnectApp extends StatelessWidget {
  const MethodistConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Methodist Connect',
      home: Scaffold(
        body: Center(child: Text('Welcome')),
      ),
    );
  }
}
