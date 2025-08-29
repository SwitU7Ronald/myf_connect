import 'package:flutter/material.dart';

// Auth & home
import '../pages/auth/welcome_page.dart';
import '../pages/auth/signup_details_page.dart';
import '../pages/home/main_menu_page.dart';
import '../pages/home/credit_page.dart';
import '../pages/home/profile_page.dart';

// Camps (user)
import '../pages/camps/camps_list_page.dart';
import '../pages/camps/camps_detail_page.dart';

// MYF (user)
import '../pages/myfs/myfs_list_page.dart';
import '../pages/myfs/myfs_detail_page.dart';

// Admin sections
import '../pages/admin/admin_dashboard_page.dart';

// Admin: Camps
import '../pages/admin/camps_manage/camps_management_page.dart';
import '../pages/admin/camps_manage/camps_create_page.dart';
import '../pages/admin/camps_manage/camps_events_management_page.dart';

// Admin: MYF
import '../pages/admin/myfs_manage/myfs_management_page.dart';
import '../pages/admin/myfs_manage/myfs_create_page.dart';
import '../pages/admin/myfs_manage/myfs_events_management_page.dart';

// Admin: Users
import '../pages/admin/users_manage/users_management_page.dart';

class AppRoutes {
  // Public/auth
  static const welcome = '/';
  static const signupDetails = '/auth/details';
  static const mainMenu = '/home';
  static const credit = '/credit';
  static const profile = '/home/profile';

  // Camps (user)
  static const campsList = '/home/camps';
  static const campsDetail = '/home/camps/detail';

  // MYF (user)
  static const myfsList = '/home/myfs';
  static const myfsDetail = '/home/myfs/detail';

  // Admin
  static const adminDashboard = '/admin';

  // Admin: Camps
  static const campsManagement = '/admin/camps/manage';
  static const campsCreate = '/admin/camps/create';
  static const campsEventsManagement = '/admin/camps/events';

  // Admin: MYF
  static const myfsManagement = '/admin/myfs';
  static const myfsCreate = '/admin/myfs/create';
  static const myfsEventsManagement = '/admin/myfs/events';

  // Admin: Users
  static const usersManagement = '/admin/users/manage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth & home
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case signupDetails:
        return MaterialPageRoute(builder: (_) => const SignupDetailsPage());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case credit:
        return MaterialPageRoute(builder: (_) => const CreditPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // Camps (user)
      case campsList:
        return MaterialPageRoute(builder: (_) => const CampsListPage());
      case campsDetail:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('campId') ||
              !args.containsKey('campTitle')) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Missing campId or campTitle')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => CampsDetailPage(
              campId: args['campId'],
              campTitle: args['campTitle'],
            ),
          );
        }

      // MYF (user)
      case myfsList:
        return MaterialPageRoute(builder: (_) => const MyfsListPage());
      case myfsDetail:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('myfId') ||
              !args.containsKey('myfTitle')) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Missing myfId or myfTitle')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => MyfsDetailPage(
              myfId: args['myfId'],
              myfTitle: args['myfTitle'],
            ),
          );
        }

      // Admin hub
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      // Admin: Camps
      case campsManagement:
        return MaterialPageRoute(builder: (_) => const CampsManagementPage());
      case campsCreate:
        return MaterialPageRoute(builder: (_) => const CampsCreatePage());
      case campsEventsManagement:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('campId') ||
              !args.containsKey('campTitle')) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Missing campId or campTitle')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => CampsEventsManagementPage(
              campId: args['campId'],
              campTitle: args['campTitle'],
            ),
          );
        }

      // Admin: MYF
      case myfsManagement:
        return MaterialPageRoute(builder: (_) => const MyfsManagementPage());
      case myfsCreate:
        return MaterialPageRoute(builder: (_) => const MyfsCreatePage());
      case myfsEventsManagement:
        {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('myfId') ||
              !args.containsKey('myfTitle')) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Missing myfId or myfTitle')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => MyfsEventsManagementPage(
              myfId: args['myfId'],
              myfTitle: args['myfTitle'],
            ),
          );
        }

      // Admin: Users
      case usersManagement:
        return MaterialPageRoute(builder: (_) => const UsersManagementPage());

      // Fallback safely to welcome
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
