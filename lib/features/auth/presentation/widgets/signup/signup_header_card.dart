import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


/// A decorative header card shown at the top of the signup details page.
class SignupHeaderCard extends StatelessWidget {
  const SignupHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MyfCard(
      padding: EdgeInsets.all(context.spacingLg),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacingMd),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: context.radiusXl,
            ),
            child: Icon(
              Icons.person_add,
              size: context.responsiveIconSize(48),
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacingMd),
          Text(
            'Complete Your Profile',
            style: context.typography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacingSm),
          Text(
            'We\'ve pre-filled some details from your Google account',
            style: context.typography.bodyMedium!.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
