import 'package:flutter/material.dart';
import '../pages/home/credit_page.dart';
import '../pages/home/team_page.dart';
import '../pages/auth/welcome_page.dart';
import '../pages/auth/signup_details_page.dart';
import '../pages/home/main_menu_page.dart';
import '../pages/home/profile_page.dart';
import '../pages/camps/camps_list_page.dart';
import '../pages/camps/camps_detail_page.dart';
import '../pages/myfs/myfs_list_page.dart';
import '../pages/myfs/myfs_detail_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../main.dart';

class AppRoutes {
  // Route names
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

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    debugPrint('Navigating to route: ${settings.name}');

    switch (settings.name) {
      case root:
        return MaterialPageRoute(
          builder: (_) => const AuthGateWrapper(),
          settings: settings,
        );

      case credit:
        return MaterialPageRoute(
          builder: (_) => const CreditPage(),
          settings: settings,
        );

      case team:
        return MaterialPageRoute(
          builder: (_) => const TeamPage(),
          settings: settings,
        );

      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
          settings: settings,
        );

      case signupDetails:
        return MaterialPageRoute(
          builder: (_) => const SignupDetailsPage(),
          settings: settings,
        );

      case mainMenu:
        return MaterialPageRoute(
          builder: (_) => const MainMenuPage(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case campsList:
        return MaterialPageRoute(
          builder: (_) => const CampsListPage(),
          settings: settings,
        );

      case campsDetail:
        final args = settings.arguments as Map<String, String>?;
        if (args == null) {
          return _errorRoute('Missing camp details');
        }
        return MaterialPageRoute(
          builder: (_) => CampsDetailPage(
            campId: args['campId']!,
            campTitle: args['campTitle']!,
          ),
          settings: settings,
        );

      case myfsList:
        return MaterialPageRoute(
          builder: (_) => const MyfsListPage(),
          settings: settings,
        );

      case myfsDetail:
        final args = settings.arguments as Map<String, String>?;
        if (args == null) {
          return _errorRoute('Missing MYF details');
        }
        return MaterialPageRoute(
          builder: (_) => MyfsDetailPage(
            myfId: args['myfId']!,
            myfTitle: args['myfTitle']!,
          ),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
          settings: settings,
        );

      default:
        debugPrint('Unknown route: ${settings.name}');
        return _errorRoute('Page not found');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.root,
                      (route) => false,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
