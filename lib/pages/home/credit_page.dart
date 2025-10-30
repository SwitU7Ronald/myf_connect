import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/app_router.dart';
import '../../app/theme.dart';
import '../../widgets/widgets.dart';

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  bool _loading = false;

  Future<void> _navigateNext() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.primaryRed,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            // ✅ RESPONSIVE: Use context.responsivePadding
            padding: context.responsivePadding(all: 24),
            child: Column(
              children: [
                SizedBox(height: context.spacing(24)),

                // Logo/Icon
                Container(
                  padding: context.responsivePadding(all: 24),
                  decoration: BoxDecoration(
                    color: MethodistTheme.white.withValues(alpha: 0.1),
                    // ✅ RESPONSIVE: Use context.responsiveRadius
                    borderRadius: BorderRadius.circular(
                      context.responsiveRadius(20),
                    ),
                  ),
                  // ✅ RESPONSIVE: Use context.responsiveIconSize
                  child: Icon(
                    Icons.church,
                    size: context.responsiveIconSize(80),
                    color: MethodistTheme.white,
                  ),
                ),

                SizedBox(height: context.spacing(24)),

                // Title
                Text(
                  'Methodist Connect',
                  // ✅ RESPONSIVE: Use responsive text style
                  style: context.responsiveDisplayMedium.copyWith(
                    color: MethodistTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing(12)),

                // Subtitle
                Text(
                  'Connect with Methodist Camps & MYF',
                  style: context.responsiveBodyLarge.copyWith(
                    color: MethodistTheme.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing(48)),

                // Credits section
                MethodistCard(
                  color: MethodistTheme.white.withValues(alpha: 0.1),
                  padding: context.responsivePadding(all: 20),
                  child: Column(
                    children: [
                      Text(
                        'Developed by',
                        style: context.responsiveBodyMedium.copyWith(
                          color: MethodistTheme.white.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: context.spacing(8)),
                      Text(
                        'Methodist Connect Team',
                        style: context.responsiveTitleLarge.copyWith(
                          color: MethodistTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.spacing(4)),
                      Text(
                        'Version 1.0.0',
                        style: context.responsiveBodySmall.copyWith(
                          color: MethodistTheme.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing(48)),

                // Team Members Section
                Text(
                  'Our Team',
                  style: context.responsiveHeadlineMedium.copyWith(
                    color: MethodistTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing(16)),

                // Team Members List - Priority Order

                // 1. Youth Director (First)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Ankur_Thakor-GRC-MYF-Youth-Director.jpg',
                  name: 'Ankur Thakor',
                  position: 'GRC MYF Youth Director',
                ),

                SizedBox(height: context.spacing(16)),

                // 2. Advisor (Second)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Akash_Khristi-GRC-MYF-Advisor.jpg',
                  name: 'Akash Khristi',
                  position: 'GRC MYF Advisor',
                ),

                SizedBox(height: context.spacing(16)),

                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Nevil_Christian-Advisor.jpg',
                  name: 'Nevil Christian',
                  position: 'GRC MYF Advisor',
                ),

                SizedBox(height: context.spacing(16)),

                // 3. President (Third)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Christian-President.jpg',
                  name: 'Chris Christian',
                  position: 'Team President',
                ),

                SizedBox(height: context.spacing(16)),

                // 4. Secretary (Fourth)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Khristi-Secretary.jpg',
                  name: 'Chris Khristi',
                  position: 'Team Secretary',
                ),

                SizedBox(height: context.spacing(16)),

                // 5. Treasurer (Fifth)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Morlins_Macwan-Treasurer.jpg',
                  name: 'Morlins Macwan',
                  position: 'Team Treasurer',
                ),

                SizedBox(height: context.spacing(16)),

                // Rest of the team members
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Christian-Sports-Entertainment-President.jpg',
                  name: 'Chris Christian',
                  position: 'Sports & Entertainment Lead',
                ),

                SizedBox(height: context.spacing(16)),

                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Kuldeep_Gohel-Convenor-Physical-Arrangements.jpg',
                  name: 'Kuldeep Gohel',
                  position: 'Convenor - Physical Arrangements',
                ),

                SizedBox(height: context.spacing(16)),

                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Maxwell_Parmar-Frontend-Designer.jpg',
                  name: 'Maxwell Parmar',
                  position: 'App Designer',
                ),

                SizedBox(height: context.spacing(16)),

                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Kshitij_Parmar-Developer.jpeg',
                  name: 'Kshitij Parmar',
                  position: 'App Developer',
                ),

                SizedBox(height: context.spacing(48)),

                // Continue button
                PrimaryButton.secondary(
                  label: _loading
                      ? 'Loading...'
                      : (Navigator.of(context).canPop() ? 'Back' : 'Continue'),
                  onPressed: _loading ? null : _navigateNext,
                  loading: _loading,
                  fullWidth: true,
                  icon: Navigator.of(context).canPop()
                      ? Icons.arrow_back
                      : Icons.arrow_forward,
                ),

                SizedBox(height: context.spacing(48)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ RESPONSIVE: Build team member card with responsive sizing
  Widget _buildTeamMemberCard(
      BuildContext context, {
        required String imagePath,
        required String name,
        required String position,
      }) {
    // ✅ RESPONSIVE: Use context.responsiveIconSize for avatar
    final avatarSize = context.responsiveIconSize(70);

    return MethodistCard(
      color: MethodistTheme.white.withValues(alpha: 0.1),
      padding: context.responsivePadding(all: 16),
      child: Row(
        children: [
          // Profile Image - ✅ RESPONSIVE
          ClipRRect(
            borderRadius: BorderRadius.circular(
              context.responsiveRadius(12),
            ),
            child: Image.asset(
              imagePath,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: MethodistTheme.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      context.responsiveRadius(12),
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: context.responsiveIconSize(35),
                    color: MethodistTheme.white.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: context.spacing(16)),

          // Name and Position - ✅ RESPONSIVE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.responsiveTitleLarge.copyWith(
                    color: MethodistTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  position,
                  style: context.responsiveBodyMedium.copyWith(
                    color: MethodistTheme.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
