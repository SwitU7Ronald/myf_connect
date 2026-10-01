import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/features/home/presentation/pages/credit_page.dart';
import 'package:myf_connect/features/home/presentation/pages/team_page.dart';
import 'package:myf_connect/features/auth/presentation/pages/welcome_page.dart';
import 'package:myf_connect/features/auth/presentation/pages/signup_details_page.dart';
import 'package:myf_connect/features/home/presentation/pages/main_menu_page.dart';
import 'package:myf_connect/features/auth/presentation/pages/profile_page.dart';
import 'package:myf_connect/features/camps/presentation/pages/camps_list_page.dart';
import 'package:myf_connect/features/camps/presentation/pages/camps_detail_page.dart';
import 'package:myf_connect/features/myfs/presentation/pages/myfs_list_page.dart';
import 'package:myf_connect/features/myfs/presentation/pages/myfs_detail_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/users_manage/users_management_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/camps_manage/camps_management_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/myfs_manage/myfs_management_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/camps_manage/camps_create_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/camps_manage/camps_events_management_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/myfs_manage/myfs_create_page.dart';
import 'package:myf_connect/features/admin/presentation/pages/myfs_manage/myfs_events_management_page.dart';
import 'package:myf_connect/features/auth/presentation/widgets/auth_gate_wrapper.dart';
import 'package:myf_connect/features/auth/presentation/widgets/admin_guard.dart';

class AppRoutes {
  static const String root = '/';
  static const String credit = '/credit';
  static const String team = '/team';
  static const String welcome = '/welcome';
  static const String signupDetails = '/signup-details';
  static const String mainMenu = '/main-menu';
  static const String profile = '/profile';
  static const String campsList = '/camps-list';
  static const String campsDetail = '/camps-detail';
  static const String myfsList = '/myfs-list';
  static const String myfsDetail = '/myfs-detail';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminUsers = '/admin-users';
  static const String adminCamps = '/admin-camps';
  static const String adminMyfs = '/admin-myfs';
  static const String adminCampsCreate = '/admin-camps-create';
  static const String adminCampsEvents = '/admin-camps-events';
  static const String adminMyfsCreate = '/admin-myfs-create';
  static const String adminMyfsEvents = '/admin-myfs-events';

  static final GoRouter router = GoRouter(
    initialLocation: root,
    routes: [
      GoRoute(path: root, builder: (context, state) => const AuthGateWrapper()),
      GoRoute(path: credit, builder: (context, state) => const CreditPage()),
      GoRoute(path: team, builder: (context, state) => const TeamPage()),
      GoRoute(path: welcome, builder: (context, state) => const WelcomePage()),
      GoRoute(
        path: signupDetails,
        builder: (context, state) => const SignupDetailsPage(),
      ),
      GoRoute(
        path: mainMenu,
        builder: (context, state) => const MainMenuPage(),
      ),
      GoRoute(path: profile, builder: (context, state) => const ProfilePage()),
      GoRoute(
        path: campsList,
        builder: (context, state) => const CampsListPage(),
      ),
      GoRoute(
        path: campsDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CampsDetailPage(
            campId: extra?['campId'] ?? '',
            campTitle: extra?['campTitle'] ?? '',
          );
        },
      ),
      GoRoute(
        path: myfsList,
        builder: (context, state) => const MyfsListPage(),
      ),
      GoRoute(
        path: myfsDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyfsDetailPage(
            myfId: extra?['myfId'] ?? '',
            myfTitle: extra?['myfTitle'] ?? '',
          );
        },
      ),
      GoRoute(
        path: adminDashboard,
        builder: (context, state) =>
            const AdminGuard(child: AdminDashboardPage()),
      ),
      GoRoute(
        path: adminUsers,
        builder: (context, state) =>
            const AdminGuard(child: UsersManagementPage()),
      ),
      GoRoute(
        path: adminCamps,
        builder: (context, state) =>
            const AdminGuard(child: CampsManagementPage()),
      ),
      GoRoute(
        path: adminMyfs,
        builder: (context, state) =>
            const AdminGuard(child: MyfsManagementPage()),
      ),
      GoRoute(
        path: adminCampsCreate,
        builder: (context, state) => const AdminGuard(child: CampsCreatePage()),
      ),
      GoRoute(
        path: adminCampsEvents,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AdminGuard(
            child: CampsEventsManagementPage(
              campId: extra?['campId'] ?? '',
              campTitle: extra?['campTitle'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: adminMyfsCreate,
        builder: (context, state) => const AdminGuard(child: MyfsCreatePage()),
      ),
      GoRoute(
        path: adminMyfsEvents,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AdminGuard(
            child: MyfsEventsManagementPage(
              myfId: extra?['myfId'] ?? '',
              myfTitle: extra?['myfTitle'] ?? '',
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.error}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(root),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
