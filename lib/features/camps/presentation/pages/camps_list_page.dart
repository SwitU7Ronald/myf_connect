import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/camps/presentation/bloc/camps_bloc.dart';
import 'package:myf_connect/features/events/presentation/cubit/rating_cubit.dart';

class CampsListPage extends StatelessWidget {
  const CampsListPage({super.key});

  void _handleCampTap(
    BuildContext context,
    String campId,
    String campTitle,
    List<String> userPermissions,
  ) {
    if (userPermissions.contains(campId)) {
      debugPrint('CampsListPage: User has permission for $campTitle');
      context.push(
        AppRoutes.campsDetail,
        extra: {'campId': campId, 'campTitle': campTitle},
      );
    } else {
      debugPrint('CampsListPage: User lacks permission for $campTitle');
      MyfTheme.showErrorSnackBar(
        context,
        'Access Denied: You need admin approval to view "$campTitle". Please contact an administrator.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<CampsBloc>()..add(CampsSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Camps')),
        body: BlocBuilder<CampsBloc, CampsState>(
          builder: (context, state) {
            if (state.status == CampsStatus.initial ||
                state.status == CampsStatus.loading) {
              return const LoadingWidget(message: 'Loading camps...');
            }

            if (state.status == CampsStatus.failure) {
              return ErrorStateWidget(
                title: 'Error Loading Camps',
                description: 'Failed to load camps: ${state.errorMessage}',
                onRetry: () {
                  context.read<CampsBloc>().add(CampsSubscriptionRequested());
                },
              );
            }

            final camps = state.camps;
            final userPermissions = state.userPermissions;

            if (camps.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.campaign,
                title: 'No Camps Available',
                description: 'Check back later for upcoming camps and events.',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                if (isWide) {
                  return GridView.builder(
                    padding: MyfTheme.paddingM,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 180,
                        ),
                    itemCount: camps.length,
                    itemBuilder: (context, index) {
                      return _buildCampItem(
                        context,
                        camps[index],
                        userPermissions,
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: MyfTheme.paddingM,
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    return _buildCampItem(
                      context,
                      camps[index],
                      userPermissions,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCampItem(
    BuildContext context,
    dynamic camp,
    List<String> userPermissions,
  ) {
    final campId = camp.id;
    final title = camp.title;
    final place = camp.place;
    final description = camp.description;

    String dateStr = '';
    final dateVal = camp.date;
    if (dateVal != null) {
      dateStr = dateVal.toLocal().toString().split(' ').first;
    }

    final hasPermission = userPermissions.contains(campId);

    return InfoCard(
      title: title,
      subtitle: place.isNotEmpty ? place : null,
      description: '$dateStr${description.isNotEmpty ? ' • $description' : ''}',
      icon: Icons.campaign,
      isLocked: !hasPermission,
      onTap: () => _handleCampTap(context, campId, title, userPermissions),
      trailing: BlocProvider(
        create: (context) => di.sl<RatingCubit>(
          param1: campId,
          param2: true,
        )..loadRating(),
        child: BlocBuilder<RatingCubit, RatingState>(
          builder: (context, state) {
            if (state is! RatingLoaded || state.count == 0) {
              return const SizedBox.shrink();
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: MyfTheme.warningOrange, size: 18),
                SizedBox(width: MyfTheme.spacingXS),
                Text(
                  state.avgRating.toStringAsFixed(1),
                  style: MyfTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: MyfTheme.warningOrange,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
