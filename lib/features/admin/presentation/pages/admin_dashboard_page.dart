import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.background,
      appBar: PlatformAppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
        child: ResponsiveConstrainedBox(
          maxWidth: 600,
          child: Column(
            children: [
              MyfCard(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: context.radiusXl,
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: context.spacingMd),
                    Text(
                      'Admin Dashboard',
                      style: context.typography.headlineSmall!,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacingSm),
                    Text(
                      'Manage users, camps, and MYF groups',
                      style: context.typography.bodyMedium!.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacingLg),

              InfoCard(
                title: 'Users Management',
                description: 'Approve users and manage permissions',
                icon: Icons.people,
                onTap: () {
                  context.push(AppRoutes.adminMyfs);
                },
              ),

              SizedBox(height: context.spacingMd),

              InfoCard(
                title: 'Camps Management',
                description: 'Create, edit, delete camps and events',
                icon: Icons.campaign,
                onTap: () {
                  context.push(AppRoutes.adminCamps);
                },
              ),

              SizedBox(height: context.spacingMd),

              InfoCard(
                title: 'MYF Management',
                description: 'Manage MYF groups and their events',
                icon: Icons.group,
                onTap: () {
                  context.push(AppRoutes.adminMyfs);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
