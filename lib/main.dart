import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'firebase_options.dart';
import 'app/app_router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintBeginFrameBanner = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MethodistConnectApp());
}

class MethodistConnectApp extends StatelessWidget {
  const MethodistConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Methodist Connect',
      theme: MethodistTheme.theme, // Changed from themeData to theme
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
          return Scaffold(
            backgroundColor: MethodistTheme.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(MethodistTheme.primaryRed),
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Loading...',
                    style: MethodistTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Handle auth stream errors
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: MethodistTheme.lightGray,
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: MethodistTheme.primaryRed,
              foregroundColor: MethodistTheme.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 64,
                    color: MethodistTheme.errorRed,
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Authentication Error: ${snapshot.error}',
                    style: MethodistTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      // Force restart the auth check
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.root,
                            (route) => false,
                      );
                    },
                    style: MethodistTheme.primaryButtonStyle,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Prevent multiple navigation calls
        if (_navigated) {
          return Scaffold(
            backgroundColor: MethodistTheme.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(MethodistTheme.primaryRed),
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Navigating...',
                    style: MethodistTheme.bodyMedium,
                  ),
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

          return Scaffold(
            backgroundColor: MethodistTheme.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(MethodistTheme.primaryRed),
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Signing in...',
                    style: MethodistTheme.bodyMedium,
                  ),
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

        return Scaffold(
          backgroundColor: MethodistTheme.lightGray,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MethodistTheme.primaryRed),
                ),
                SizedBox(height: MethodistTheme.spacingM),
                Text(
                  'Initializing...',
                  style: MethodistTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}