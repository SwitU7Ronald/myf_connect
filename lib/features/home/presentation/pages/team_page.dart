import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('TeamPage Initialized');
  }

  void navigateNext() async {
    if (loading) return;

    debugPrint('TeamPage Continue button pressed');

    setState(() {
      loading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final canPop = context.canPop();

      debugPrint('TeamPage canPop: $canPop, user: ${user?.uid}');

      if (canPop) {
        debugPrint('TeamPage Going back');
        context.pop();
      } else if (user != null) {
        debugPrint('TeamPage User authenticated, going to main menu');
        context.go(AppRoutes.mainMenu);
      } else {
        debugPrint('TeamPage No user, going to welcome page');
        context.go(AppRoutes.welcome);
      }
    } catch (e) {
      debugPrint('TeamPage Navigation error: $e');

      if (mounted) {
        MyfTheme.showErrorSnackBar(context, 'Navigation error: $e');
        context.go(AppRoutes.welcome);
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyfTheme.primaryRed,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MyfTheme.paddingL,
          child: Column(
            children: [
              SizedBox(height: MyfTheme.spacingL),
              Container(
                padding: MyfTheme.paddingL,
                decoration: BoxDecoration(
                  color: MyfTheme.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MyfTheme.radiusXXL),
                ),
                child: Icon(Icons.people, size: 80, color: MyfTheme.white),
              ),
              SizedBox(height: MyfTheme.spacingL),
              Text(
                'MYF Team',
                style: MyfTheme.displayMedium.copyWith(color: MyfTheme.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MyfTheme.spacingS),
              Text(
                'Meet the Leadership',
                style: MyfTheme.bodyLarge.copyWith(
                  color: MyfTheme.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MyfTheme.spacingXL),
              MyfCard(
                color: MyfTheme.white.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Leadership Team',
                      style: MyfTheme.titleLarge.copyWith(
                        color: MyfTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MyfTheme.spacingM),
                    Text(
                      'The MYF MYF is led by dedicated individuals committed to serving the MYF with passion and dedication.',
                      style: MyfTheme.bodyMedium.copyWith(
                        color: MyfTheme.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MyfTheme.spacingXL),
              Text(
                'Our Team',
                style: MyfTheme.headlineSmall.copyWith(
                  color: MyfTheme.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MyfTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'President',
                      name: 'Chris Christian',
                      location: 'A\'bad West',
                    ),
                  ),
                  SizedBox(width: MyfTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Vice President',
                      name: 'Simon Khristi',
                      location: 'Umreth',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MyfTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Secretary',
                      name: 'Crish Parmar',
                      location: 'Kathlal',
                    ),
                  ),
                  SizedBox(width: MyfTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Treasurer',
                      name: 'Morlins Mekwan',
                      location: 'Vadodara',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MyfTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Evangelism & Worship',
                      name: 'Sam Christi',
                      location: 'A\'bad North',
                    ),
                  ),
                  SizedBox(width: MyfTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Nutrition & Stewardship',
                      name: 'Mahima Parmar',
                      location: 'Anand',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MyfTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Music & Entertainment',
                      name: 'Alex Roy',
                      location: 'Nadiad',
                    ),
                  ),
                  SizedBox(width: MyfTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Outreach & Mission',
                      name: 'Alina Gohil',
                      location: 'Bharuch-Surat',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MyfTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Regional, National & Int\'l Social Affairs',
                      name: 'Praizy Christian',
                      location: 'A\'bad East',
                    ),
                  ),
                  SizedBox(width: MyfTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Sports & Games',
                      name: 'Chris J Christian',
                      location: 'Godhra',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MyfTheme.spacingXL),
              PrimaryButton.secondary(
                label: loading
                    ? 'Loading...'
                    : context.canPop()
                    ? 'Back'
                    : 'Continue',
                onPressed: loading ? null : navigateNext,
                loading: loading,
                fullWidth: true,
                icon: context.canPop() ? Icons.arrow_back : Icons.arrow_forward,
              ),
              SizedBox(height: MyfTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String position,
    required String name,
    required String location,
  }) {
    return MyfCard(
      color: MyfTheme.white.withValues(alpha: 0.1),
      child: SizedBox(
        height: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: MyfTheme.spacingXS),
                  child: Text(
                    position,
                    style: MyfTheme.titleSmall.copyWith(
                      color: MyfTheme.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: MyfTheme.titleMedium.copyWith(
                    color: MyfTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: MyfTheme.white.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: MyfTheme.bodySmall.copyWith(
                          color: MyfTheme.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
