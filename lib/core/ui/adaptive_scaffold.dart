import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';

class AdaptiveScaffold extends StatefulWidget {
  final Widget child;

  const AdaptiveScaffold({super.key, required this.child});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.mainMenu)) return 0;
    if (location.startsWith(AppRoutes.campsList)) return 1;
    if (location.startsWith(AppRoutes.myfsList)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.mainMenu);
      case 1:
        context.go(AppRoutes.campsList);
      case 2:
        context.go(AppRoutes.myfsList);
      case 3:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = context.isTablet;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: context.colors.primary),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.campaign_outlined),
        selectedIcon: Icon(Icons.campaign, color: context.colors.primary),
        label: 'Camps',
      ),
      NavigationDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people, color: context.colors.primary),
        label: 'MYFs',
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: context.colors.primary),
        label: 'Profile',
      ),
    ];

    final railDestinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: context.colors.primary),
        label: const Text('Home'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.campaign_outlined),
        selectedIcon: Icon(Icons.campaign, color: context.colors.primary),
        label: const Text('Camps'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people, color: context.colors.primary),
        label: const Text('MYFs'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: context.colors.primary),
        label: const Text('Profile'),
      ),
    ];

    Widget buildRail({bool extended = false}) {
      return NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: railDestinations,
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        extended: extended,
        backgroundColor: context.colors.surface,
        selectedIconTheme: IconThemeData(color: context.colors.primary),
        unselectedIconTheme: IconThemeData(color: context.colors.textSecondary),
        indicatorColor: context.colors.primary.withValues(alpha: 0.12),
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: context.spacingLg),
          child: Column(
            children: [
              Container(
                width: extended ? 40 : 36,
                height: extended ? 40 : 36,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.church,
                  color: context.colors.surface,
                  size: extended ? 22 : 18,
                ),
              ),
              if (extended) ...[
                SizedBox(height: context.spacingSm),
                Text(
                  'MYF Connect',
                  style: context.typography.titleSmall!.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return PlatformScaffold(
        body: widget.child,
        bottomNavigationBar: LiquidGlassContainer(
          borderRadius: 0,
          baseColor: Colors.transparent,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (idx) => _onItemTapped(idx, context),
            destinations: destinations,
            backgroundColor: context.colors.surface.withValues(alpha: 0.95),
            indicatorColor: context.colors.primary.withValues(alpha: 0.12),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      );
    }

    return PlatformScaffold(
      body: SafeArea(
        child: Row(
          children: [
            buildRail(extended: !isTablet),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
