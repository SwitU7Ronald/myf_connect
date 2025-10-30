import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../app/theme.dart';
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
        title: Text(
          'Methodist Connect',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        elevation: 4,
        shadowColor: MethodistTheme.darkGray.withValues(alpha: 0.5),
        actions: [
          // Admin Dashboard Button
          if (_isAdmin)
            Tooltip(
              message: 'Admin Dashboard',
              child: IconButton(
                icon: Icon(
                  Icons.admin_panel_settings,
                  size: context.responsiveIconSize(24),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.adminDashboard),
              ),
            ),
          // Profile Button
          Tooltip(
            message: 'Profile',
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                size: context.responsiveIconSize(24),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ),
          // Add responsive spacing
          SizedBox(width: context.spacing(8)),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading...')
          : SingleChildScrollView(
        padding: context.responsivePadding(all: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ FIXED: Welcome section with proper alignment
            MethodistCard(
              padding: context.responsivePadding(all: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: context.responsivePadding(all: 16),
                    decoration: BoxDecoration(
                      color: MethodistTheme.primaryRed.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(
                        context.responsiveRadius(24),
                      ),
                    ),
                    child: Icon(
                      Icons.church,
                      size: context.responsiveIconSize(56),
                      color: MethodistTheme.primaryRed,
                    ),
                  ),
                  SizedBox(height: context.spacing(20)),
                  Text(
                    'Welcome to Methodist Connect',
                    style: context.responsiveHeadlineMedium.copyWith(
                      color: MethodistTheme.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacing(12)),
                  Text(
                    'Connect with camps and MYF groups',
                    style: context.responsiveBodyMedium.copyWith(
                      color: MethodistTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.spacing(28)),

            // ✅ FIXED: Feature cards with proper layout
            FeatureCard(
              title: 'Camps',
              description: 'Explore Methodist camps and events',
              icon: Icons.campaign,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.campsList),
            ),

            SizedBox(height: context.spacing(16)),

            FeatureCard(
              title: 'MYF Groups',
              description: 'Connect with Methodist Youth Fellowship',
              icon: Icons.people,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.myfsList),
            ),

            SizedBox(height: context.spacing(28)),
          ],
        ),
      ),
    );
  }
}
