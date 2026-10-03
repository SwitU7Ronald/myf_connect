import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


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
            return PlatformScaffold(
              appBar: PlatformAppBar(title: const Text('Access Denied')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: context.responsiveIconSize(64),
                      color: context.errorColor,
                    ),
                    SizedBox(height: context.spacingMd),
                    const Text('You do not have permission to view this page.'),
                    SizedBox(height: context.spacingMd),
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
          return const PlatformScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Unauthenticated or Error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.root);
          });
          return const PlatformScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
