import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'users_manage/users_management_page.dart';
import 'camps_manage/camps_management_page.dart';
import 'myfs_manage/myfs_management_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: MethodistTheme.paddingM,
        child: Column(
          children: [
            // Welcome section
            MethodistCard(
              child: Column(
                children: [
                  Container(
                    padding: MethodistTheme.paddingM,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.radiusXL),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: context.primaryColor,
                    ),
                  ),
                  SizedBox(height: context.spacingM),
                  Text(
                    'Admin Dashboard',
                    style: context.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacingS),
                  Text(
                    'Manage users, camps, and MYF groups',
                    style: context.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.spacingL),

            // Management cards
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

            SizedBox(height: context.spacingM),

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

            SizedBox(height: context.spacingM),

            InfoCard(
              title: 'MYF Management',
              description: 'Manage MYF groups and events',
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyfsManagementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}