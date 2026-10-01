import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

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
        MyfTheme.showErrorSnackBar(context, 'Navigation error: $e');
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
    return Scaffold(
      backgroundColor: MyfTheme.primaryRed,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: MyfTheme.paddingL,
              child: ElevatedButton(
                onPressed: _loading ? null : _navigateNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyfTheme.white,
                  foregroundColor: MyfTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: MyfTheme.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MyfTheme.radiusL),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: MyfTheme.primaryRed,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.canPop() ? 'Back' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                child: Icon(Icons.church, size: 80, color: MyfTheme.white),
              ),

              SizedBox(height: MyfTheme.spacingL),

              Text(
                'MYF Connect',
                style: MyfTheme.displayMedium.copyWith(color: MyfTheme.white),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MyfTheme.spacingL),

              Text(
                'Leaders',
                style: MyfTheme.headlineMedium.copyWith(
                  color: MyfTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MyfTheme.spacingL),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/mock_avatar.jpg',
                      name: 'Honourable Bishop\nA Simeon',
                    ),
                  ),

                  SizedBox(width: MyfTheme.spacingL),

                  Expanded(
                    child: _buildRoundedTeamLeaderCard(
                      imagePath: 'assets/mock_avatar.jpg',
                      name: 'Madam Leena\nGloria',
                    ),
                  ),
                ],
              ),

              SizedBox(height: MyfTheme.spacingL),

              Text(
                'Our Team',
                style: MyfTheme.headlineMedium.copyWith(
                  color: MyfTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Ankur Thakor',
                position: 'GRC MYF Youth Director',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Akash Khristi',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Nevil Christian',
                position: 'GRC MYF Advisor',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Christian',
                position: 'Team President',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Khristi',
                position: 'Team Secretary',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Morlins Mekwan',
                position: 'Team Treasurer',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Chris Christian',
                position: 'Sports & Entertainment Lead',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Kuldeep Gohel',
                position: 'Convenor - Physical Arrangements',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Maxwell Parmar',
                position: 'App Convener',
              ),

              SizedBox(height: MyfTheme.spacingM),

              _buildTeamMemberCard(
                imagePath: 'assets/mock_avatar.jpg',
                name: 'Kshitij Parmar',
                position: 'App Developer',
              ),

              SizedBox(height: MyfTheme.spacingXL),
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
              color: MyfTheme.white.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: MyfTheme.black.withValues(alpha: 0.3),
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

        SizedBox(height: MyfTheme.spacingM),

        Text(
          name,
          style: MyfTheme.titleSmall.copyWith(
            color: MyfTheme.white,
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
      color: MyfTheme.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MyfTheme.radiusL),
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
                    color: MyfTheme.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(MyfTheme.radiusL),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: MyfTheme.white.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: MyfTheme.spacingM),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: MyfTheme.titleLarge.copyWith(
                    color: MyfTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MyfTheme.spacingXS),
                Text(
                  position,
                  style: MyfTheme.bodyMedium.copyWith(
                    color: MyfTheme.white.withValues(alpha: 0.8),
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
