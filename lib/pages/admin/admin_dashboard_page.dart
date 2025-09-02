import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../admin/camps_manage/camps_management_page.dart';
import '../admin/myfs_manage/myfs_management_page.dart';
import '../admin/users_manage/users_management_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: context.primaryColor,
        foregroundColor: context.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: MethodistTheme.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
                    style: context.headlineSmall.copyWith(
                      color: context.textPrimary,
                    ),
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

            // Management Cards
            InfoCard(
              title: 'User Management',
              description: 'Manage user permissions and approvals',
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
              description: 'Create and manage camps and their events',
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

            SizedBox(height: context.spacingL),

            // Statistics Cards Row
            Row(
              children: [
                Expanded(
                  child: MethodistCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 32,
                          color: context.infoBlue,
                        ),
                        SizedBox(height: context.spacingS),
                        Text(
                          'Users',
                          style: context.labelMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.spacingXS),
                        Text(
                          '-',
                          style: context.titleLarge.copyWith(
                            color: context.infoBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: context.spacingM),
                Expanded(
                  child: MethodistCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 32,
                          color: context.warningColor,
                        ),
                        SizedBox(height: context.spacingS),
                        Text(
                          'Camps',
                          style: context.labelMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.spacingXS),
                        Text(
                          '-',
                          style: context.titleLarge.copyWith(
                            color: context.warningColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: context.spacingM),
                Expanded(
                  child: MethodistCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.group,
                          size: 32,
                          color: context.successColor,
                        ),
                        SizedBox(height: context.spacingS),
                        Text(
                          'MYFs',
                          style: context.labelMedium.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.spacingXS),
                        Text(
                          '-',
                          style: context.titleLarge.copyWith(
                            color: context.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}