import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAdmin = state is AuthAuthenticated && state.isAdmin;

        return Scaffold(
          backgroundColor: context.colors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: context.colors.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: context.spacingLg,
                    bottom: context.spacingMd,
                  ),
                  title: Text(
                    'Today',
                    style: context.typography.headlineMedium!.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                actions: [
                  if (isAdmin)
                    Tooltip(
                      message: 'Admin Dashboard',
                      child: IconButton(
                        icon: Icon(
                          Icons.admin_panel_settings,
                          size: context.responsiveIconSize(24),
                          color: context.colors.textPrimary,
                        ),
                        onPressed: () => context.push(AppRoutes.adminDashboard),
                      ),
                    ),
                  SizedBox(width: context.spacingSm),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacingLg,
                  vertical: context.spacingMd,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _VerseOfTheDayCard(),
                    SizedBox(height: context.spacingXxl),
                    Text(
                      'Featured Events',
                      style: context.typography.titleLarge,
                    ),
                    SizedBox(height: context.spacingMd),
                    const _FeaturedEventsFeed(),
                    SizedBox(height: context.spacingXxl),
                    Text(
                      'Explore Communities',
                      style: context.typography.titleLarge,
                    ),
                    SizedBox(height: context.spacingMd),
                    const _CommunitiesFeed(),
                    SizedBox(height: context.spacing(80)), // Padding for bottom nav
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerseOfTheDayCard extends StatelessWidget {
  const _VerseOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    return MyfCard(
      padding: EdgeInsets.zero,
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.primary,
                  context.colors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 200,
                    color: context.colors.surface.withValues(alpha: 0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(context.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'VERSE OF THE DAY',
                        style: context.typography.labelSmall!.copyWith(
                          color: context.colors.surface.withValues(alpha: 0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: context.spacingXs),
                      Text(
                        'Philippians 4:13',
                        style: context.typography.headlineSmall!.copyWith(
                          color: context.colors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(context.spacingXl),
            child: Column(
              children: [
                Text(
                  '"I can do all things through Christ who strengthens me."',
                  style: context.typography.headlineMedium!.copyWith(
                    color: context.colors.textPrimary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: context.colors.textSecondary),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.bookmark_border, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedEventsFeed extends StatelessWidget {
  const _FeaturedEventsFeed();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(width: context.spacingMd),
        itemBuilder: (context, index) {
          final titles = ['Youth Retreat 2026', 'Sunday Worship', 'Community Service'];
          final dates = ['Oct 15 - 18', 'Every Sunday', 'Nov 2'];
          return SizedBox(
            width: 280,
            child: MyfCard(
              padding: EdgeInsets.zero,
              color: context.colors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event,
                        size: 48,
                        color: context.colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: context.typography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.spacingXs),
                        Text(
                          dates[index],
                          style: context.typography.bodySmall!.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CommunitiesFeed extends StatelessWidget {
  const _CommunitiesFeed();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        final titles = ['Methodist Youth Fellowship', 'Young Adults Ministry', 'Choir Ministry'];
        return Padding(
          padding: EdgeInsets.only(bottom: context.spacingMd),
          child: MyfCard(
            padding: EdgeInsets.all(context.spacingMd),
            color: context.colors.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.people, color: context.colors.primary),
                ),
                SizedBox(width: context.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[index],
                        style: context.typography.titleMedium,
                      ),
                      SizedBox(height: context.spacingXs),
                      Text(
                        'Join the community and grow together.',
                        style: context.typography.bodySmall!.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.textSecondary),
              ],
            ),
          ),
        );
      }),
    );
  }
}
