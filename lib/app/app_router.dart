import 'package:flutter/material.dart';
import '../pages/auth/welcome_page.dart';
import '../pages/auth/signup_details_page.dart';
import '../pages/home/main_menu_page.dart';
import '../pages/home/profile_page.dart';
import '../pages/camps/camps_list_page.dart';
import '../pages/myf/myf_list_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/myf_create_page.dart';
import '../pages/admin/myf_management_page.dart';
import '../pages/home/credit_page.dart'; // CreditPage import

class AppRoutes {
  static const welcome = '/';
  static const credit = '/credit';
  static const signupDetails = '/auth/details';
  static const mainMenu = '/home';
  static const profile = '/home/profile';
  static const camps = '/home/camps';
  static const godhraCamp = '/home/camps/godhra2025';
  static const adminDashboard = '/admin';
  static const myfList = '/home/myf';
  static const myfManagement = '/admin/myf';
  static const myfCreate = '/admin/myf/create';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case credit:
        return MaterialPageRoute(builder: (_) => const CreditPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case signupDetails:
        return MaterialPageRoute(builder: (_) => const SignupDetailsPage());
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case camps:
        return MaterialPageRoute(builder: (_) => const CampsListPage());
      case myfList:
        return MaterialPageRoute(builder: (_) => const MyfListPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case myfManagement:
        return MaterialPageRoute(builder: (_) => const MyfManagementPage());
      case myfCreate:
        return MaterialPageRoute(builder: (_) => const MyfCreatePage());
      default:
      // Fallback safely to welcome
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
