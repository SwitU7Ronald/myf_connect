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

  String _capitalizeEachWord(String str) {
    if (str.isEmpty) return '';
    return str.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  Map<String, String> _extractNamesFromDisplayName(String displayName) {
    String firstName = '';
    String lastName = '';
    String nickname = '';

    if (displayName.isEmpty) return {'firstName': '', 'lastName': '', 'nickname': ''};

    final nicknameRegExp = RegExp(r'\(([^)]+)\)');
    final nicknameMatch = nicknameRegExp.firstMatch(displayName);

    if (nicknameMatch != null) {
      nickname = _capitalizeEachWord(nicknameMatch.group(1)?.trim() ?? '');
    }

    String cleanedName = displayName.replaceAll(nicknameRegExp, '').trim();

    final List<String> nameParts = cleanedName.split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isNotEmpty) {
      firstName = _capitalizeEachWord(nameParts.first);

      if (nameParts.length > 1) {
        lastName = _capitalizeEachWord(nameParts.sublist(1).join(' '));
      }
    }

    if (nickname.isEmpty && firstName.isNotEmpty) {
      nickname = firstName;
    }

    return {
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
    };
  }

  Future<void> _continueWithGoogle() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      if (!mounted) return;

      final userService = UserService();
      final appUser = await userService.getUser(firebaseUser.uid);

      if (!mounted) return;

      if (appUser != null && appUser.isProfileComplete) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
      } else {
        final displayName = googleUser.displayName ?? '';
        final extractedNames = _extractNamesFromDisplayName(displayName);

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signupDetails,
          arguments: {
            'email': googleUser.email,
            'displayName': displayName,
            'firstName': extractedNames['firstName'],
            'lastName': extractedNames['lastName'],
            'nickname': extractedNames['nickname'],
            'photoURL': googleUser.photoUrl,
            'isNewUser': appUser == null,
          },
        );
      }
    } catch (e) {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {}

      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Sign-in error: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.primaryRed,
      body: SafeArea(
        child: Padding(
          // ✅ RESPONSIVE: Use context.responsivePadding
          padding: context.responsivePadding(all: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Icon
              Container(
                padding: context.responsivePadding(all: 24),
                decoration: BoxDecoration(
                  color: MethodistTheme.white.withValues(alpha: 0.1),
                  // ✅ RESPONSIVE: Use context.responsiveRadius
                  borderRadius: BorderRadius.circular(
                    context.responsiveRadius(20),
                  ),
                ),
                // ✅ RESPONSIVE: Use context.responsiveIconSize
                child: Icon(
                  Icons.church,
                  size: context.responsiveIconSize(80),
                  color: MethodistTheme.white,
                ),
              ),

              SizedBox(height: context.spacing(24)),

              // Title
              Text(
                'MYF Connect',
                // ✅ RESPONSIVE: Use responsive text style
                style: context.responsiveDisplayMedium.copyWith(
                  color: MethodistTheme.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing(12)),

              // Subtitle
              Text(
                'Connect with Methodist Camps & MYF',
                // ✅ RESPONSIVE: Use responsive text style
                style: context.responsiveBodyLarge.copyWith(
                  color: MethodistTheme.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing(48)),

              // Description Card
              MethodistCard(
                color: MethodistTheme.white.withValues(alpha: 0.1),
                padding: context.responsivePadding(all: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: context.responsiveIconSize(24),
                      color: MethodistTheme.white,
                    ),
                    SizedBox(height: context.spacing(12)),
                    Text(
                      'Sign in with your Google account to get started',
                      style: context.responsiveBodyMedium.copyWith(
                        color: MethodistTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing(32)),

              // Sign-in Button
              PrimaryButton(
                label: 'Continue with Google',
                onPressed: _continueWithGoogle,
                loading: _loading,
                fullWidth: true,
                icon: Icons.login,
              ),

              SizedBox(height: context.spacing(12)),

              // Credits Button
              PrimaryButton.secondary(
                label: 'Credits',
                onPressed: _loading ? null : () {
                  Navigator.pushNamed(context, AppRoutes.credit);
                },
                fullWidth: true,
                icon: Icons.info,
              ),

              const Spacer(),

              // Version Info
              Text(
                'Version 1.0.0',
                style: context.responsiveBodySmall.copyWith(
                  color: MethodistTheme.white.withValues(alpha: 0.5),
                ),
              ),

              SizedBox(height: context.spacing(8)),
            ],
          ),
        ),
      ),
    );
  }
}
