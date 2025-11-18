import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../widgets/widgets.dart';

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
      final canPop = Navigator.of(context).canPop();

      debugPrint('TeamPage canPop: $canPop, user: ${user?.uid}');

      if (canPop) {
        debugPrint('TeamPage Going back');
        Navigator.pop(context);
      } else if (user != null) {
        debugPrint('TeamPage User authenticated, going to main menu');
        await Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
      } else {
        debugPrint('TeamPage No user, going to welcome page');
        await Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    } catch (e) {
      debugPrint('TeamPage Navigation error: $e');

      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Navigation error: $e');
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
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
      backgroundColor: MethodistTheme.primaryRed,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MethodistTheme.paddingL,
          child: Column(
            children: [
              SizedBox(height: MethodistTheme.spacingL),
              Container(
                padding: MethodistTheme.paddingL,
                decoration: BoxDecoration(
                  color: MethodistTheme.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MethodistTheme.radiusXXL),
                ),
                child: Icon(
                  Icons.people,
                  size: 80,
                  color: MethodistTheme.white,
                ),
              ),
              SizedBox(height: MethodistTheme.spacingL),
              Text(
                'Methodist MYF Team',
                style: MethodistTheme.displayMedium.copyWith(
                  color: MethodistTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MethodistTheme.spacingS),
              Text(
                'Meet the Leadership',
                style: MethodistTheme.bodyLarge.copyWith(
                  color: MethodistTheme.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MethodistTheme.spacingXL),
              MethodistCard(
                color: MethodistTheme.white.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Leadership Team',
                      style: MethodistTheme.titleLarge.copyWith(
                        color: MethodistTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    Text(
                      'The Methodist MYF is led by dedicated individuals committed to serving the Methodist Youth Fellowship with passion and dedication.',
                      style: MethodistTheme.bodyMedium.copyWith(
                        color: MethodistTheme.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MethodistTheme.spacingXL),
              Text(
                'Our Team',
                style: MethodistTheme.headlineSmall.copyWith(
                  color: MethodistTheme.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MethodistTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'President',
                      name: 'Chris Christian',
                      location: 'A\'bad West',
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Vice President',
                      name: 'Simon Khristi',
                      location: 'Umreth',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MethodistTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Secretary',
                      name: 'Crish Parmar',
                      location: 'Kathlal',
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Treasurer',
                      name: 'Morlins Mekwan',
                      location: 'Vadodara',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MethodistTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Evangelism & Worship',
                      name: 'Sam Christi',
                      location: 'A\'bad North',
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Nutrition & Stewardship',
                      name: 'Mahima Parmar',
                      location: 'Anand',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MethodistTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Music & Entertainment',
                      name: 'Alex Roy',
                      location: 'Nadiad',
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Outreach & Mission',
                      name: 'Alina Gohil',
                      location: 'Bharuch-Surat',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MethodistTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Regional, National & Int\'l Social Affairs',
                      name: 'Praizy Christian',
                      location: 'A\'bad East',
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Sports & Games',
                      name: 'Chris J Christian',
                      location: 'Godhra',
                    ),
                  ),
                ],
              ),
              SizedBox(height: MethodistTheme.spacingXL),
              PrimaryButton.secondary(
                label: loading
                    ? 'Loading...'
                    : Navigator.of(context).canPop()
                    ? 'Back'
                    : 'Continue',
                onPressed: loading ? null : navigateNext,
                loading: loading,
                fullWidth: true,
                icon: Navigator.of(context).canPop()
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
              ),
              SizedBox(height: MethodistTheme.spacingXL),
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
    return MethodistCard(
      color: MethodistTheme.white.withValues(alpha: 0.1),
      child: SizedBox(
        height: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: MethodistTheme.spacingXS),
                  child: Text(
                    position,
                    style: MethodistTheme.titleSmall.copyWith(
                      color: MethodistTheme.white.withValues(alpha: 0.7),
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
                  style: MethodistTheme.titleMedium.copyWith(
                    color: MethodistTheme.white,
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
                      color: MethodistTheme.white.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: MethodistTheme.bodySmall.copyWith(
                          color: MethodistTheme.white.withValues(alpha: 0.6),
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
