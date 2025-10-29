// ./lib/pages/home/credit_page.dart
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
        child: Padding(
          padding: MethodistTheme.paddingL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Icon
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

              // Title
              Text(
                'Methodist Connect',
                style: MethodistTheme.displayMedium.copyWith(
                  color: MethodistTheme.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: MethodistTheme.spacingM),

              // Subtitle
              Text(
                'Connect with Methodist Camps & MYF',
                style: MethodistTheme.bodyLarge.copyWith(
                  color: MethodistTheme.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Credits section
              MethodistCard(
                color: MethodistTheme.white.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Developed by',
                      style: MethodistTheme.bodyMedium.copyWith(
                        color: MethodistTheme.white.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: MethodistTheme.spacingS),
                    Text(
                      'Methodist Connect Team',
                      style: MethodistTheme.titleLarge.copyWith(
                        color: MethodistTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MethodistTheme.spacingXS),
                    Text(
                      'Version 1.0.0',
                      style: MethodistTheme.bodySmall.copyWith(
                        color: MethodistTheme.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MethodistTheme.spacingL),

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

              SizedBox(height: MethodistTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
