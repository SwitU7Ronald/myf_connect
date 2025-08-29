import 'package:flutter/material.dart';
import '../pages/auth/welcome_page.dart';
import '../pages/auth/signup_details_page.dart';
import '../pages/home/main_menu_page.dart';
import '../pages/camps/camps_list_page.dart';
import '../pages/myfs/myfs_list_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/myfs_manage//myfs_management_page.dart';
import '../pages/admin/myfs_manage/myfs_create_page.dart';
import '../pages/home/credit_page.dart';
import '../pages/home/profile_page.dart';

class AppRoutes {
  static const welcome = '/';
  static const signupDetails = '/auth/details';
  static const mainMenu = '/home';
  static const campsList = '/home/camps';
  static const myfsList = '/home/myfs';
  static const adminDashboard = '/admin';
  static const myfsManagement = '/admin/myfs';
  static const myfsCreate = '/admin/myfs/create';
  static const credit = '/credit';
  static const profile = '/home/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case signupDetails:
        return MaterialPageRoute(builder: (_) => const SignupDetailsPage());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case campsList:
        return MaterialPageRoute(builder: (_) => const CampsListPage());
      case myfsList:
        return MaterialPageRoute(builder: (_) => const MyfsListPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case myfsManagement:
        return MaterialPageRoute(builder: (_) => const MyfsManagementPage());
      case myfsCreate:
        return MaterialPageRoute(builder: (_) => const MyfsCreatePage());
      case credit:
        return MaterialPageRoute(builder: (_) => const CreditPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
      // Fallback safely to welcome
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
