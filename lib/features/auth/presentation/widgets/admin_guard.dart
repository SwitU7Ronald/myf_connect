import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myf_connect/core/config/app_router.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.isAdmin) {
            return child;
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text('Access Denied')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('You do not have permission to view this page.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.mainMenu),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Unauthenticated or Error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.root);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
