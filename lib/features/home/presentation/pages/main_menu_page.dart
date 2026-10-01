import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAdmin = state is AuthAuthenticated && state.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'MYF Connect',
              style: context.responsiveHeadlineSmall.copyWith(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (isAdmin)
                Tooltip(
                  message: 'Admin Dashboard',
                  child: IconButton(
                    icon: Icon(
                      Icons.admin_panel_settings,
                      size: context.responsiveIconSize(24),
                    ),
                    onPressed: () => context.push(AppRoutes.adminDashboard),
                  ),
                ),
              Tooltip(
                message: 'Profile',
                child: IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    size: context.responsiveIconSize(24),
                  ),
                  onPressed: () => context.push(AppRoutes.profile),
                ),
              ),
              SizedBox(width: context.spacing(8)),
            ],
          ),
          body: SingleChildScrollView(
            padding: context.responsivePadding(all: 20),
            child: ResponsiveConstrainedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyfCard(
                    padding: context.responsivePadding(all: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: context.responsivePadding(all: 12),
                          decoration: BoxDecoration(
                            color: MyfTheme.primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveRadius(16),
                            ),
                          ),
                          child: Icon(
                            Icons.church,
                            size: context.responsiveIconSize(40),
                            color: MyfTheme.primaryRed,
                          ),
                        ),
                        SizedBox(height: context.spacing(12)),
                        Text(
                          'Welcome to MYF Connect',
                          style: context.responsiveTitleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacing(8)),
                        Text(
                          'Connect with camps and MYF groups',
                          style: context.responsiveBodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.spacing(28)),

                  FeatureCard(
                    title: 'Camps',
                    description: 'Explore MYF camps and events',
                    icon: Icons.campaign,
                    onTap: () => context.push(AppRoutes.campsList),
                  ),

                  SizedBox(height: context.spacing(16)),

                  FeatureCard(
                    title: 'MYF Groups',
                    description: 'Connect with MYF',
                    icon: Icons.people,
                    onTap: () => context.push(AppRoutes.myfsList),
                  ),

                  SizedBox(height: context.spacing(28)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
