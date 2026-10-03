import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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

          context.go(
            AppRoutes.signupDetails,
            extra: {
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
          AppSnackbars.showError(
            context,
            'Sign-in error: ${state.message}',
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return PlatformScaffold(
          backgroundColor: context.colors.primary,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.spacingLg),
              child: Center(
                // Ensures proper centering on ultra-wide Mac screens
                child: ResponsiveConstrainedBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // This pattern allows Spacers to work while still providing scrolling on small desktop windows
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),

                                Container(
                                  padding: EdgeInsets.all(context.spacingLg),
                                  decoration: BoxDecoration(
                                    color: context.colors.surface.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      context.radiusXl.topLeft.x,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.church,
                                    size: context.responsiveIconSize(80),
                                    color: context.colors.surface,
                                  ),
                                ),

                                SizedBox(height: context.spacingLg),

                                Text(
                                  'MYF Connect',
                                  style: context.responsiveDisplayMedium
                                      .copyWith(color: context.colors.surface),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: context.spacingMd),

                                Text(
                                  'Connect with MYF Camps & MYF',
                                  style: context.typography.bodyLarge!.copyWith(
                                    color: context.colors.surface.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: context.spacingXxl),

                                MyfCard(
                                  color: context.colors.surface.withValues(
                                    alpha: 0.1,
                                  ),
                                  padding: EdgeInsets.all(context.spacingLg),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: context.responsiveIconSize(24),
                                        color: context.colors.surface,
                                      ),
                                      SizedBox(height: context.spacingMd),
                                      Text(
                                        AppStrings.signInWithGooglePrompt,
                                        style: context.typography.bodyMedium!
                                            .copyWith(
                                              color: context.colors.surface,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: context.spacingXl),

                                PrimaryButton(
                                  label: AppStrings.continueWithGoogle,
                                  onPressed: isLoading
                                      ? null
                                      : _continueWithGoogle,
                                  loading: isLoading,
                                  fullWidth: true,
                                  icon: Icons.login,
                                ),

                                SizedBox(height: context.spacingMd),

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
                                  style: context.typography.bodySmall!.copyWith(
                                    color: context.colors.surface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),

                                SizedBox(height: context.spacingSm),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
