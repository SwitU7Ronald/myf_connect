import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app/firebase_options.dart';
import 'app/app_router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MethodistConnectApp());
}

class MethodistConnectApp extends StatelessWidget {
  const MethodistConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Methodist Connect',
      theme: MethodistTheme.themeData,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.root,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGateWrapper extends StatefulWidget {
  const AuthGateWrapper({super.key});

  @override
  State<AuthGateWrapper> createState() => _AuthGateWrapperState();
}

class _AuthGateWrapperState extends State<AuthGateWrapper> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('AuthGateWrapper: Connection state: ${snapshot.connectionState}');
        debugPrint('AuthGateWrapper: Has data: ${snapshot.hasData}');
        debugPrint('AuthGateWrapper: User: ${snapshot.data?.uid}');

        // Show loading while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Handle auth stream errors
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Authentication Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Force restart the auth check
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.root,
                            (route) => false,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Prevent multiple navigation calls
        if (_navigated) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Navigating...'),
                ],
              ),
            ),
          );
        }

        // User is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('AuthGateWrapper: User is authenticated, navigating to main menu');

          // Use addPostFrameCallback to avoid navigation during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_navigated) {
              setState(() => _navigated = true);
              Navigator.of(context).pushReplacementNamed(AppRoutes.mainMenu);
            }
          });

          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Signing in...'),
                ],
              ),
            ),
          );
        }

        // User is not authenticated - show credit page first
        debugPrint('AuthGateWrapper: User is not authenticated, showing credit page');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_navigated) {
            setState(() => _navigated = true);
            Navigator.of(context).pushReplacementNamed(AppRoutes.credit);
          }
        });

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing...'),
              ],
            ),
          ),
        );
      },
    );
  }
}