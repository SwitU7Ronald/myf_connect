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
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: SingleChildScrollView(
        padding: MethodistTheme.paddingM,
        child: Column(
          children: [
            MethodistCard(
              child: Column(
                children: [
                  Container(
                    padding: MethodistTheme.paddingM,
                    decoration: BoxDecoration(
                      color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        MethodistTheme.radiusXL,
                      ),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: MethodistTheme.primaryRed,
                    ),
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Admin Dashboard',
                    style: MethodistTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MethodistTheme.spacingS),
                  Text(
                    'Manage users, camps, and MYF groups',
                    style: MethodistTheme.bodyMedium.copyWith(
                      color: MethodistTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: MethodistTheme.spacingL),

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

            SizedBox(height: MethodistTheme.spacingM),

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

            SizedBox(height: MethodistTheme.spacingM),

            InfoCard(
              title: 'MYF Management',
              description: 'Manage MYF groups and their events',
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyfsManagementPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
