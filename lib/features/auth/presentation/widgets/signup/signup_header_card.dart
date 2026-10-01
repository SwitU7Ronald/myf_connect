import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

/// A decorative header card shown at the top of the signup details page.
class SignupHeaderCard extends StatelessWidget {
  const SignupHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MyfCard(
      padding: context.responsivePadding(all: 20),
      child: Column(
        children: [
          Container(
            padding: context.responsivePadding(all: 16),
            decoration: BoxDecoration(
              color: MyfTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                context.responsiveRadius(20),
              ),
            ),
            child: Icon(
              Icons.person_add,
              size: context.responsiveIconSize(48),
              color: MyfTheme.primaryRed,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            'Complete Your Profile',
            style: context.responsiveHeadlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacing(8)),
          Text(
            'We\'ve pre-filled some details from your Google account',
            style: context.responsiveBodyMedium.copyWith(
              color: MyfTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
