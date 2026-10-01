import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _capitalizeEachWord(String str) {
    if (str.isEmpty) return '';
    return str
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() +
              (word.length > 1 ? word.substring(1).toLowerCase() : '');
        })
        .join(' ');
  }

  Map<String, String> _extractNamesFromDisplayName(String displayName) {
    String firstName = '';
    String lastName = '';
    String nickname = '';

    if (displayName.isEmpty) {
      return {'firstName': '', 'lastName': '', 'nickname': ''};
    }

    final nicknameRegExp = RegExp(r'\(([^)]+)\)');
    final nicknameMatch = nicknameRegExp.firstMatch(displayName);

    if (nicknameMatch != null) {
      nickname = _capitalizeEachWord(nicknameMatch.group(1)?.trim() ?? '');
    }

    String cleanedName = displayName.replaceAll(nicknameRegExp, '').trim();

    final List<String> nameParts = cleanedName
        .split(' ')
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

    return {'firstName': firstName, 'lastName': lastName, 'nickname': nickname};
  }

  void _continueWithGoogle() {
    context.read<AuthBloc>().add(AuthLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.mainMenu);
        } else if (state is AuthNeedsProfileCompletion) {
          final displayName = state.user.displayName ?? '';
          final extractedNames = _extractNamesFromDisplayName(displayName);

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.signupDetails,
            arguments: {
              'email': state.user.email,
              'displayName': displayName,
              'firstName': extractedNames['firstName'],
              'lastName': extractedNames['lastName'],
              'nickname': extractedNames['nickname'],
              'photoURL': state.user.photoURL,
              'isNewUser': state.isNewUser,
            },
          );
        } else if (state is AuthError) {
          MyfTheme.showErrorSnackBar(
            context,
            'Sign-in error: ${state.message}',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: MyfTheme.primaryRed,
          body: SafeArea(
            child: Padding(
              padding: context.responsivePadding(all: 24),
              child: ResponsiveConstrainedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    Container(
                      padding: context.responsivePadding(all: 24),
                      decoration: BoxDecoration(
                        color: MyfTheme.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          context.responsiveRadius(20),
                        ),
                      ),
                      child: Icon(
                        Icons.church,
                        size: context.responsiveIconSize(80),
                        color: MyfTheme.white,
                      ),
                    ),

                    SizedBox(height: context.spacing(24)),

                    Text(
                      'MYF Connect',
                      style: context.responsiveDisplayMedium.copyWith(
                        color: MyfTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing(12)),

                    Text(
                      'Connect with MYF Camps & MYF',
                      style: context.responsiveBodyLarge.copyWith(
                        color: MyfTheme.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing(48)),

                    MyfCard(
                      color: MyfTheme.white.withValues(alpha: 0.1),
                      padding: context.responsivePadding(all: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: context.responsiveIconSize(24),
                            color: MyfTheme.white,
                          ),
                          SizedBox(height: context.spacing(12)),
                          Text(
                            AppStrings.signInWithGooglePrompt,
                            style: context.responsiveBodyMedium.copyWith(
                              color: MyfTheme.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.spacing(32)),

                    PrimaryButton(
                      label: AppStrings.continueWithGoogle,
                      onPressed: isLoading ? null : _continueWithGoogle,
                      loading: isLoading,
                      fullWidth: true,
                      icon: Icons.login,
                    ),

                    SizedBox(height: context.spacing(12)),

                    PrimaryButton.secondary(
                      label: AppStrings.credits,
                      onPressed: isLoading
                          ? null
                          : () {
                              context.push(AppRoutes.credit);
                            },
                      fullWidth: true,
                      icon: Icons.info,
                    ),

                    const Spacer(),

                    Text(
                      'Version 1.0.0',
                      style: context.responsiveBodySmall.copyWith(
                        color: MyfTheme.white.withValues(alpha: 0.5),
                      ),
                    ),

                    SizedBox(height: context.spacing(8)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
