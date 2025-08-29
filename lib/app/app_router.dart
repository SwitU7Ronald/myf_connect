import 'package:flutter/material.dart';
import '../pages/auth/welcome_page.dart';
import '../pages/auth/signup_details_page.dart';
import '../pages/home/main_menu_page.dart';
import '../pages/camps/camps_list_page.dart';
import '../pages/myf/myf_list_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/myf_management_page.dart';
import '../pages/admin/myf_create_page.dart';
import '../pages/home/credit_page.dart';
import '../pages/home/profile_page.dart';

class AppRoutes {
  static const welcome = '/';
  static const signupDetails = '/auth/details';
  static const mainMenu = '/home';
  static const campsList = '/home/camps';
  static const myfList = '/home/myf';
  static const adminDashboard = '/admin';
  static const myfManagement = '/admin/myf';
  static const myfCreate = '/admin/myf/create';
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
      case myfList:
        return MaterialPageRoute(builder: (_) => const MyfListPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case myfManagement:
        return MaterialPageRoute(builder: (_) => const MyfManagementPage());
      case myfCreate:
        return MaterialPageRoute(builder: (_) => const MyfCreatePage());
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
