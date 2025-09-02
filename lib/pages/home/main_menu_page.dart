import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../widgets/widgets.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult(true);
        final adminClaim = idTokenResult.claims?['admin'] == true;
        if (mounted) {
          setState(() {
            _isAdmin = adminClaim;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Load admin claim error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Methodist Connect'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        elevation: 0,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Dashboard',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading...')
          : SingleChildScrollView(
        padding: MethodistTheme.paddingL,
        child: Column(
          children: [
            // Welcome section
            MethodistCard(
              child: Column(
                children: [
                  Container(
                    padding: MethodistTheme.paddingM,
                    decoration: BoxDecoration(
                      color: MethodistTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusXL),
                    ),
                    child: Icon(
                      Icons.church,
                      size: 48,
                      color: MethodistTheme.primaryRed,
                    ),
                  ),
                  SizedBox(height: MethodistTheme.spacingM),
                  Text(
                    'Welcome to Methodist Connect',
                    style: MethodistTheme.headlineMedium.copyWith(
                      color: MethodistTheme.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MethodistTheme.spacingS),
                  Text(
                    'Connect with camps and MYF groups',
                    style: MethodistTheme.bodyMedium.copyWith(
                      color: MethodistTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: MethodistTheme.spacingL),

            // Feature cards (only Camps and MYF)
            FeatureCard(
              title: 'Camps',
              description: 'Explore Methodist camps and events',
              icon: Icons.campaign,
              onTap: () => Navigator.pushNamed(context, AppRoutes.campsList),
            ),

            SizedBox(height: MethodistTheme.spacingM),

            FeatureCard(
              title: 'MYF Groups',
              description: 'Connect with Methodist Youth Fellowship',
              icon: Icons.people,
              onTap: () => Navigator.pushNamed(context, AppRoutes.myfsList),
            ),
          ],
        ),
      ),
    );
  }
}
