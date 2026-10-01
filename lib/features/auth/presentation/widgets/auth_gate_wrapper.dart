import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/themes/theme.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';

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
          return Scaffold(
            backgroundColor: MyfTheme.lightGray,
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: MyfTheme.primaryRed,
              foregroundColor: MyfTheme.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: MyfTheme.errorRed),
                  SizedBox(height: MyfTheme.spacingM),
                  Text(
                    'Authentication Error: ${state.message}',
                    style: MyfTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MyfTheme.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                    },
                    style: MyfTheme.primaryButtonStyle,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: MyfTheme.lightGray,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MyfTheme.primaryRed,
                  ),
                ),
                SizedBox(height: MyfTheme.spacingM),
                Text(
                  _navigated ? 'Navigating...' : 'Loading...',
                  style: MyfTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
