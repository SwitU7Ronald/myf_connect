import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../widgets/widgets.dart';

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
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final canPop = Navigator.of(context).canPop();

      debugPrint('CreditPage: canPop=$canPop, user=${user?.uid}');

      if (canPop) {
        debugPrint('CreditPage: Going back');
        Navigator.pop(context);
      } else {
        if (user != null) {
          debugPrint('CreditPage: User authenticated, going to main menu');
          await Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
        } else {
          debugPrint('CreditPage: No user, going to welcome page');
          await Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        }
      }
    } catch (e) {
      debugPrint('CreditPage: Navigation error: $e');
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Navigation error: $e');
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
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
                  Icons.church,
                  size: 80,
                  color: MethodistTheme.white,
                ),
              ),

              SizedBox(height: MethodistTheme.spacingL),

              Text(
                'MYF Connect',
                style: MethodistTheme.displayMedium.copyWith(
                  color: MethodistTheme.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MethodistTheme.spacingL),

              Text(
                'Leaders',
                style: MethodistTheme.headlineMedium.copyWith(
                  color: MethodistTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MethodistTheme.spacingL),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/team/Honourable_A.Simeon-Bishop.jpeg',
                      name: 'Honourable Bishop\nA Simeon',
                    ),
                  ),

                  SizedBox(width: MethodistTheme.spacingL),

                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/team/Leena_Gloria-Madam.jpeg',
                      name: 'Madam Leena\nGloria',
                    ),
                  ),
                ],
              ),

              SizedBox(height: MethodistTheme.spacingL),

              Text(
                'Our Team',
                style: MethodistTheme.headlineMedium.copyWith(
                  color: MethodistTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath:
                    'assets/team/Ankur_Thakor-GRC-MYF-Youth-Director.jpg',
                name: 'Ankur Thakor',
                position: 'GRC MYF Youth Director',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Akash_Khristi-GRC-MYF-Advisor.jpg',
                name: 'Akash Khristi',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Nevil_Christian-Advisor.jpg',
                name: 'Nevil Christian',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Chris_Christian-President.jpg',
                name: 'Chris Christian',
                position: 'Team President',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Chris_Khristi-Secretary.jpg',
                name: 'Chris Khristi',
                position: 'Team Secretary',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Morlins_Mekwan-Treasurer.jpg',
                name: 'Morlins Mekwan',
                position: 'Team Treasurer',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath:
                    'assets/team/Chris_Christian-Sports-Entertainment-President.jpg',
                name: 'Chris Christian',
                position: 'Sports & Entertainment Lead',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath:
                    'assets/team/Kuldeep_Gohel-Convenor-Physical-Arrangements.jpg',
                name: 'Kuldeep Gohel',
                position: 'Convenor - Physical Arrangements',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Maxwell_Parmar-Frontend-Designer.jpg',
                name: 'Maxwell Parmar',
                position: 'App Convener',
              ),

              SizedBox(height: MethodistTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/team/Kshitij_Parmar-Developer.jpeg',
                name: 'Kshitij Parmar',
                position: 'App Developer',
              ),

              SizedBox(height: MethodistTheme.spacingXL),

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

              SizedBox(height: MethodistTheme.spacingXL),
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
          width: 120,
          height: 120,
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
                    color: Colors.grey,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: MethodistTheme.spacingM),

        Text(
          name,
          style: MethodistTheme.titleSmall.copyWith(
            color: MethodistTheme.white,
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
    return MethodistCard(
      color: MethodistTheme.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MethodistTheme.radiusL),
            child: Image.asset(
              imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: MethodistTheme.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(MethodistTheme.radiusL),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: MethodistTheme.white.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: MethodistTheme.spacingM),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: MethodistTheme.titleLarge.copyWith(
                    color: MethodistTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MethodistTheme.spacingXS),
                Text(
                  position,
                  style: MethodistTheme.bodyMedium.copyWith(
                    color: MethodistTheme.white.withValues(alpha: 0.8),
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
