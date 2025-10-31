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

                // ============================================
                // OUR TEAM SECTION HEADER
                // ============================================
                Text(
                  'Team Leader',
                  style: context.responsiveHeadlineMedium.copyWith(
                    color: MethodistTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing(24)),

                // ============================================
                // ✅ FIXED: HONORED GUESTS - Top Section (2 Images Side by Side - No Text Cutting)
                // ============================================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Honourable Bishop A. Simeon
                      _buildRoundedTeamMemberCard(
                        context,
                        imagePath: 'assets/team/Honourable_A.Simeon-Bishop.jpeg',
                        name: 'Honourable Bishop A. Simeon',
                      ),

                      SizedBox(width: context.spacing(20)),

                      // 2. Madam Leena Gloria
                      _buildRoundedTeamMemberCard(
                        context,
                        imagePath: 'assets/team/Leena_Gloria-Madam.jpeg',
                        name: 'Madam Leena Gloria',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing(48)),

                // ============================================
                // TEAM LEADERS SECTION
                // ============================================
                Text(
                  'Our Team',
                  style: context.responsiveHeadlineMedium.copyWith(
                    color: MethodistTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.spacing(16)),

                // 1. Youth Director (Ankur Thakor)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Ankur_Thakor-GRC-MYF-Youth-Director.jpg',
                  name: 'Ankur Thakor',
                  position: 'GRC MYF Youth Director',
                ),

                SizedBox(height: context.spacing(16)),

                // 2. Advisor (Akash Khristi)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Akash_Khristi-GRC-MYF-Advisor.jpg',
                  name: 'Akash Khristi',
                  position: 'GRC MYF Advisor',
                ),

                SizedBox(height: context.spacing(16)),

                // 3. Advisor (Nevil Christian)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Nevil_Christian-Advisor.jpg',
                  name: 'Nevil Christian',
                  position: 'GRC MYF Advisor',
                ),

                SizedBox(height: context.spacing(16)),

                // 4. President (Chris Christian)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Christian-President.jpg',
                  name: 'Chris Christian',
                  position: 'Team President',
                ),

                SizedBox(height: context.spacing(16)),

                // 5. Secretary (Chris Khristi)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Khristi-Secretary.jpg',
                  name: 'Chris Khristi',
                  position: 'Team Secretary',
                ),

                SizedBox(height: context.spacing(16)),

                // 6. Treasurer (Morlins Macwan)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Morlins_Macwan-Treasurer.jpg',
                  name: 'Morlins Macwan',
                  position: 'Team Treasurer',
                ),

                SizedBox(height: context.spacing(16)),

                // 7. Sports & Entertainment Lead
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Chris_Christian-Sports-Entertainment-President.jpg',
                  name: 'Chris Christian',
                  position: 'Sports & Entertainment Lead',
                ),

                SizedBox(height: context.spacing(16)),

                // 8. Convenor - Physical Arrangements
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Kuldeep_Gohel-Convenor-Physical-Arrangements.jpg',
                  name: 'Kuldeep Gohel',
                  position: 'Convenor - Physical Arrangements',
                ),

                SizedBox(height: context.spacing(16)),

                // 9. App Designer (Maxwell Parmar)
                _buildTeamMemberCard(
                  context,
                  imagePath: 'assets/team/Maxwell_Parmar-Frontend-Designer.jpg',
                  name: 'Maxwell Parmar',
                  position: 'App Designer',
                ),

                SizedBox(height: context.spacing(16)),

                // 10. App Developer (Kshitij Parmar)
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

  /// ✅ FIXED: Build rounded team member card with image and name (Side by Side) - NO TEXT CUTTING
  Widget _buildRoundedTeamMemberCard(
      BuildContext context, {
        required String imagePath,
        required String name,
      }) {
    // ✅ RESPONSIVE: Use context.responsiveIconSize for circular avatar
    final avatarSize = context.responsiveIconSize(110);
    final nameContainerWidth = context.responsiveIconSize(150); // ✅ WIDER for names - FIX

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Rounded Circular Image Container
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: MethodistTheme.white.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: MethodistTheme.black.withValues(alpha: 0.3),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MethodistTheme.primaryRed,
                  ),
                  child: Icon(
                    Icons.person,
                    size: context.responsiveIconSize(60),
                    color: MethodistTheme.white,
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: context.spacing(14)),

        // ✅ FIXED: Name Below Image with Wider Container & More Lines - NO CUTTING
        SizedBox(
          width: nameContainerWidth, // ✅ Increased width to prevent cutting
          child: Text(
            name,
            style: context.responsiveTitleSmall.copyWith(
              color: MethodistTheme.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 3, // ✅ Allow up to 3 lines for longer names
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// ✅ RESPONSIVE: Build team member card with responsive sizing (Original format)
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
