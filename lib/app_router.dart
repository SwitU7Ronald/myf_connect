import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/auth/signup_details_page.dart';
import 'pages/home/main_menu_page.dart';
import 'pages/home/profile_page.dart';
import 'pages/camps/camps_list_page.dart';
import 'pages/camps/godhra_camp_page.dart';

class AppRoutes {
  static const welcome = '/';
  static const signupDetails = '/auth/details';
  static const mainMenu = '/home';
  static const profile = '/home/profile';
  static const camps = '/home/camps';
  static const godhraCamp = '/home/camps/godhra2025';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case godhraCamp:
        return MaterialPageRoute(builder: (_) => const GodhraCampPage());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
