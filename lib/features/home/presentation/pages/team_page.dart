import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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
      await Future<void>.delayed(const Duration(milliseconds: 300));

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
        AppSnackbars.showError(context, 'Navigation error: $e');
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
    return PlatformScaffold(
      backgroundColor: context.colors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacingLg),
          child: Column(
            children: [
              SizedBox(height: context.spacingLg),
              Container(
                padding: EdgeInsets.all(context.spacingLg),
                decoration: BoxDecoration(
                  color: context.colors.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MyfTheme.radiusXXL),
                ),
                child: Icon(
                  Icons.people,
                  size: context.responsiveIconSize(80),
                  color: context.colors.surface,
                ),
              ),
              SizedBox(height: context.spacingLg),
              Text(
                'MYF Team',
                style: context.typography.displayMedium!.copyWith(
                  color: context.colors.surface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingSm),
              Text(
                'Meet the Leadership',
                style: context.typography.bodyLarge!.copyWith(
                  color: context.colors.surface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingXl),
              MyfCard(
                color: context.colors.surface.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Leadership Team',
                      style: context.typography.titleLarge!.copyWith(
                        color: context.colors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacingMd),
                    Text(
                      'The MYF MYF is led by dedicated individuals committed to serving the MYF with passion and dedication.',
                      style: context.typography.bodyMedium!.copyWith(
                        color: context.colors.surface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.spacingXl),
              Text(
                'Our Team',
                style: context.typography.headlineSmall!.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'President',
                      name: 'Chris Christian',
                      location: 'A\'bad West',
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Vice President',
                      name: 'Simon Khristi',
                      location: 'Umreth',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Secretary',
                      name: 'Crish Parmar',
                      location: 'Kathlal',
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Treasurer',
                      name: 'Morlins Mekwan',
                      location: 'Vadodara',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Evangelism & Worship',
                      name: 'Sam Christi',
                      location: 'A\'bad North',
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Nutrition & Stewardship',
                      name: 'Mahima Parmar',
                      location: 'Anand',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Music & Entertainment',
                      name: 'Alex Roy',
                      location: 'Nadiad',
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Outreach & Mission',
                      name: 'Alina Gohil',
                      location: 'Bharuch-Surat',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Regional, National & Int\'l Social Affairs',
                      name: 'Praizy Christian',
                      location: 'A\'bad East',
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                  Expanded(
                    child: _buildTeamMemberCard(
                      position: 'Sports & Games',
                      name: 'Chris J Christian',
                      location: 'Godhra',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingXl),
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
              SizedBox(height: context.spacingXl),
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
      color: context.colors.surface.withValues(alpha: 0.1),
      child: SizedBox(
        height: context.spacing(160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: context.spacingXs),
                  child: Text(
                    position,
                    style: context.typography.titleSmall!.copyWith(
                      color: context.colors.surface.withValues(alpha: 0.7),
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
                  style: context.typography.titleMedium!.copyWith(
                    color: context.colors.surface,
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
                      color: context.colors.surface.withValues(alpha: 0.6),
                      size: context.responsiveIconSize(14),
                    ),
                    SizedBox(width: context.spacingXs),
                    Expanded(
                      child: Text(
                        location,
                        style: context.typography.bodySmall!.copyWith(
                          color: context.colors.surface.withValues(alpha: 0.6),
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
