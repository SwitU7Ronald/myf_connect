// lib/pages/auth/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../widgets/widgets.dart';
import '../../services/user_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('WelcomePage: Initialized');
  }

  Future<void> _continueWithGoogle() async {
    if (_loading) return;

    debugPrint('WelcomePage: Google sign-in started');
    setState(() => _loading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint('WelcomePage: Google sign-in cancelled');
        if (mounted) setState(() => _loading = false);
        return;
      }

      debugPrint('WelcomePage: Google user obtained: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      debugPrint('WelcomePage: Firebase user signed in: ${firebaseUser.uid}');

      if (!mounted) return;

      final userService = UserService();
      final appUser = await userService.getUser(firebaseUser.uid);

      debugPrint('WelcomePage: Existing user check: ${appUser != null}');
      debugPrint('WelcomePage: Profile complete: ${appUser?.isProfileComplete ?? false}');

      if (!mounted) return;

      if (appUser != null && appUser.isProfileComplete) {
        debugPrint('WelcomePage: Navigating to main menu');
        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
      } else {
        debugPrint('WelcomePage: Navigating to signup details');

        // Extract names from display name
        final displayName = googleUser.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signupDetails,
          arguments: {
            'email': googleUser.email,
            'displayName': displayName,
            'firstName': firstName,
            'lastName': lastName,
            'photoURL': googleUser.photoUrl,
            'isNewUser': appUser == null,
          },
        );
      }
    } catch (e) {
      debugPrint('WelcomePage: Sign-in error: $e');

      // Clean up on error
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {
        debugPrint('WelcomePage: Error during cleanup');
      }

      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Sign-in error: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('WelcomePage: Building UI');

    return Scaffold(
      backgroundColor: MethodistTheme.primaryRed,
      body: SafeArea(
        child: Padding(
          padding: MethodistTheme.paddingL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Icon
              Container(
                padding: MethodistTheme.paddingL,
                decoration: BoxDecoration(
                  color: MethodistTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MethodistTheme.radiusXL),
                ),
                child: Icon(
                  Icons.church,
                  size: 80,
                  color: MethodistTheme.white,
                ),
              ),

              SizedBox(height: MethodistTheme.spacingL),

              // Title
              Text(
                'Methodist Connect',
                style: MethodistTheme.displayMedium.copyWith(color: MethodistTheme.white),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MethodistTheme.spacingM),

              // Subtitle
              Text(
                'Connect with Methodist Camps & MYF',
                style: MethodistTheme.bodyLarge.copyWith(
                  color: MethodistTheme.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Sign in button
              PrimaryButton(
                label: _loading ? 'Signing in...' : 'Continue with Google',
                onPressed: _loading ? null : _continueWithGoogle,
                loading: _loading,
                fullWidth: true,
                icon: Icons.account_circle,
              ),

              SizedBox(height: MethodistTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
