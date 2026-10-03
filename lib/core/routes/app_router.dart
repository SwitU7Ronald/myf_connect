import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/theme/theme.dart';
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
import 'package:myf_connect/core/ui/adaptive_scaffold.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


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
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(child: child),
        routes: [
          GoRoute(
            path: mainMenu,
            builder: (context, state) => const MainMenuPage(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: campsList,
            builder: (context, state) => const CampsListPage(),
          ),
          GoRoute(
            path: myfsList,
            builder: (context, state) => const MyfsListPage(),
          ),
        ],
      ),
      GoRoute(
        path: campsDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CampsDetailPage(
            campId: extra?['campId'] as String? ?? '',
            campTitle: extra?['campTitle'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: myfsDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MyfsDetailPage(
            myfId: extra?['myfId'] as String? ?? '',
            myfTitle: extra?['myfTitle'] as String? ?? '',
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
              campId: extra?['campId'] as String? ?? '',
              campTitle: extra?['campTitle'] as String? ?? '',
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
              myfId: extra?['myfId'] as String? ?? '',
              myfTitle: extra?['myfTitle'] as String? ?? '',
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Error',
          style: context.typography.headlineSmall!.copyWith(
            color: context.colors.surface,
          ),
        ),
        backgroundColor: context.errorColor,
        foregroundColor: context.colors.surface,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: context.responsiveIconSize(64),
                color: context.errorColor,
              ),
              SizedBox(height: context.spacingMd),
              Text(
                'Page not found:\n${state.error}',
                style: context.typography.bodyLarge!.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingLg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.errorColor,
                  foregroundColor: context.colors.surface,
                ),
                onPressed: () => context.go(root),
                child: const Text('Return to Safety'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
