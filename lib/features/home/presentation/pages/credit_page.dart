import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class CreditPage extends StatefulWidget {
  const CreditPage({super.key});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('CreditPage: Initialized');
  }

  void _navigateNext() async {
    if (_loading) return;

    debugPrint('CreditPage: Continue button pressed');
    setState(() => _loading = true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final canPop = context.canPop();

      debugPrint('CreditPage: canPop=$canPop, user=${user?.uid}');

      if (canPop) {
        debugPrint('CreditPage: Going back');
        context.pop();
      } else {
        if (user != null) {
          debugPrint('CreditPage: User authenticated, going to main menu');
          context.go(AppRoutes.mainMenu);
        } else {
          debugPrint('CreditPage: No user, going to welcome page');
          context.go(AppRoutes.welcome);
        }
      }
    } catch (e) {
      debugPrint('CreditPage: Navigation error: $e');
      if (mounted) {
        AppSnackbars.showError(context, 'Navigation error: $e');
        context.go(AppRoutes.welcome);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.primary,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(context.spacingLg),
              child: ElevatedButton(
                onPressed: _loading ? null : _navigateNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surface,
                  foregroundColor: context.colors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: context.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: context.radiusLg,
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.canPop() ? 'Back' : 'Continue',
                            style: context.typography.bodyMedium?.copyWith(
                              fontSize: context.responsiveFontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: context.spacingSm),
                          Icon(
                            context.canPop()
                                ? Icons.arrow_back
                                : Icons.arrow_forward,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
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
                  Icons.church,
                  size: context.responsiveIconSize(80),
                  color: context.colors.surface,
                ),
              ),

              SizedBox(height: context.spacingLg),

              Text(
                'MYF Connect',
                style: context.typography.displayMedium!.copyWith(
                  color: context.colors.surface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacingLg),

              Text(
                'Leaders',
                style: context.typography.headlineMedium!.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacingLg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/mock_avatar.jpg',
                      name: 'Honourable Bishop\nA Simeon',
                    ),
                  ),

                  SizedBox(width: context.spacingLg),

                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/mock_avatar.jpg',
                      name: 'Madam Leena\nGloria',
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacingLg),

              Text(
                'Our Team',
                style: context.typography.headlineMedium!.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Ankur Thakor',
                position: 'GRC MYF Youth Director',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Akash Khristi',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Nevil Christian',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Christian',
                position: 'Team President',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Khristi',
                position: 'Team Secretary',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Morlins Mekwan',
                position: 'Team Treasurer',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Christian',
                position: 'Sports & Entertainment Lead',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Kuldeep Gohel',
                position: 'Convenor - Physical Arrangements',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Maxwell Parmar',
                position: 'App Convener',
              ),

              SizedBox(height: context.spacingMd),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Kshitij Parmar',
                position: 'App Developer',
              ),

              SizedBox(height: context.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTeamLeaderCard({
    required String imagePath,
    required String name,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: context.spacing(120),
          height: context.spacing(120),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.surface.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.textPrimary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.textSecondary.withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    Icons.person,
                    size: context.responsiveIconSize(60),
                    color: context.colors.surface,
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: context.spacingMd),

        Text(
          name,
          style: context.typography.titleSmall!.copyWith(
            color: context.colors.surface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard({
    required String imagePath,
    required String name,
    required String position,
  }) {
    return MyfCard(
      color: context.colors.surface.withValues(alpha: 0.1),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: context.radiusLg,
            child: Image.asset(
              imagePath,
              width: context.spacing(70),
              height: context.spacing(70),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: context.spacing(70),
                  height: context.spacing(70),
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.2),
                    borderRadius: context.radiusLg,
                  ),
                  child: Icon(
                    Icons.person,
                    size: context.responsiveIconSize(35),
                    color: context.colors.surface.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: context.spacingMd),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.typography.titleLarge!.copyWith(
                    color: context.colors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacingXs),
                Text(
                  position,
                  style: context.typography.bodyMedium!.copyWith(
                    color: context.colors.surface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
