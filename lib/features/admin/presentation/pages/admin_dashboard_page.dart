import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/admin/presentation/pages/users_manage/users_management_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/camps_manage/camps_management_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyfTheme.lightGray,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: MyfTheme.primaryRed,
        foregroundColor: MyfTheme.white,
      ),
      body: SingleChildScrollView(
        padding: MyfTheme.paddingM,
        child: Column(
          children: [
            MyfCard(
              child: Column(
                children: [
                  Container(
                    padding: MyfTheme.paddingM,
                    decoration: BoxDecoration(
                      color: MyfTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MyfTheme.radiusXL),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: MyfTheme.primaryRed,
                    ),
                  ),
                  SizedBox(height: MyfTheme.spacingM),
                  Text(
                    'Admin Dashboard',
                    style: MyfTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MyfTheme.spacingS),
                  Text(
                    'Manage users, camps, and MYF groups',
                    style: MyfTheme.bodyMedium.copyWith(
                      color: MyfTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: MyfTheme.spacingL),

            InfoCard(
              title: 'Users Management',
              description: 'Approve users and manage permissions',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UsersManagementPage(),
                  ),
                );
              },
            ),

            SizedBox(height: MyfTheme.spacingM),

            InfoCard(
              title: 'Camps Management',
              description: 'Create, edit, delete camps and events',
              icon: Icons.campaign,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CampsManagementPage(),
                  ),
                );
              },
            ),

            SizedBox(height: MyfTheme.spacingM),

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
    );
  }
}
