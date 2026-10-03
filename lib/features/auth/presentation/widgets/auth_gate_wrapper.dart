import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_buttons.dart';


class AuthGateWrapper extends StatefulWidget {
  const AuthGateWrapper({super.key});

  @override
  State<AuthGateWrapper> createState() => _AuthGateWrapperState();
}

class _AuthGateWrapperState extends State<AuthGateWrapper> {
  bool _navigated = false;

  void _navigateOnce(BuildContext context, String route) {
    if (mounted && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateOnce(context, AppRoutes.mainMenu);
        } else if (state is AuthNeedsProfileCompletion) {
          _navigateOnce(context, AppRoutes.signupDetails);
        } else if (state is AuthUnauthenticated) {
          _navigateOnce(context, AppRoutes.credit);
        }
      },
      builder: (context, state) {
        if (state is AuthError) {
          return PlatformScaffold(
            backgroundColor: context.colors.background,
            appBar: PlatformAppBar(
              title: Text('Error'),
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.surface,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: context.responsiveIconSize(64),
                    color: context.colors.error,
                  ),
                  SizedBox(height: context.spacingMd),
                  Text(
                    'Authentication Error: ${state.message}',
                    style: context.typography.bodyMedium!,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingMd),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                    },
                    style: AppButtons.primary(context),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return PlatformScaffold(
          backgroundColor: context.colors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.primary,
                  ),
                ),
                SizedBox(height: context.spacingMd),
                Text(
                  _navigated ? 'Navigating...' : 'Loading...',
                  style: context.typography.bodyMedium!,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
