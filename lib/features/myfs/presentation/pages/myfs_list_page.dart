import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/myfs/presentation/bloc/myfs_bloc.dart';
import 'package:myf_connect/core/blocs/rating/rating_cubit.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


class MyfsListPage extends StatelessWidget {
  const MyfsListPage({super.key});

  void _handleMyfTap(
    BuildContext context,
    String myfId,
    String myfTitle,
    List<String> userPermissions,
  ) {
    if (userPermissions.contains(myfId)) {
      debugPrint('MyfsListPage: User has permission for $myfTitle');
      context.push(
        AppRoutes.myfsDetail,
        extra: {'myfId': myfId, 'myfTitle': myfTitle},
      );
    } else {
      debugPrint('MyfsListPage: User lacks permission for $myfTitle');
      AppSnackbars.showError(
        context,
        'Access Denied: You need admin approval to view "$myfTitle". Please contact an administrator.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<MyfsBloc>()..add(MyfsSubscriptionRequested()),
      child: PlatformScaffold(
        appBar: PlatformAppBar(title: const Text('MYF Groups')),
        body: BlocBuilder<MyfsBloc, MyfsState>(
          builder: (context, state) {
            if (state.status == MyfsStatus.initial ||
                state.status == MyfsStatus.loading) {
              return const LoadingWidget(message: 'Loading MYF groups...');
            }

            if (state.status == MyfsStatus.failure) {
              return ErrorStateWidget(
                title: 'Error Loading MYF Groups',
                description: 'Error: ${state.errorMessage}',
                onRetry: () {
                  context.read<MyfsBloc>().add(MyfsSubscriptionRequested());
                },
              );
            }

            final myfs = state.myfs;
            final userPermissions = state.userPermissions;

            if (myfs.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.group,
                title: 'No MYF Groups Available',
                description: 'Check back later for MYF groups and events.',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                if (isWide) {
                  return GridView.builder(
                    padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                    gridDelegate:
                        SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: context.spacingMd,
                          mainAxisSpacing: context.spacingMd,
                          mainAxisExtent:
                              180, // Fixed height for InfoCard in grid
                        ),
                    itemCount: myfs.length,
                    itemBuilder: (context, index) {
                      final myf = myfs[index];
                      final myfId = myf.id;
                      final title = myf.title;
                      final description = myf.description;

                      final hasPermission = userPermissions.contains(myfId);

                      return InfoCard(
                        title: title,
                        description: description.isNotEmpty
                            ? description
                            : 'No description available',
                        icon: Icons.group,
                        isLocked: !hasPermission,
                        onTap: () => _handleMyfTap(
                          context,
                          myfId,
                          title,
                          userPermissions,
                        ),
                        trailing: BlocProvider(
                          create: (context) =>
                              di.sl<RatingCubit>(param1: myfId, param2: false)
                                ..loadRating(),
                          child: BlocBuilder<RatingCubit, RatingState>(
                            builder: (context, state) {
                              if (state is! RatingLoaded || state.count == 0) {
                                return const SizedBox.shrink();
                              }

                              final avgRating = state.avgRating;

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: context.colors.warning,
                                    size: context.responsiveIconSize(18),
                                  ),
                                  SizedBox(width: context.spacingXs),
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: context.typography.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.warning,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                  itemCount: myfs.length,
                  itemBuilder: (context, index) {
                    final myf = myfs[index];
                    final myfId = myf.id;
                    final title = myf.title;
                    final description = myf.description;

                    final hasPermission = userPermissions.contains(myfId);

                    return InfoCard(
                      title: title,
                      description: description.isNotEmpty
                          ? description
                          : 'No description available',
                      icon: Icons.group,
                      isLocked: !hasPermission,
                      onTap: () =>
                          _handleMyfTap(context, myfId, title, userPermissions),
                      trailing: BlocProvider(
                        create: (context) =>
                            di.sl<RatingCubit>(param1: myfId, param2: false)
                              ..loadRating(),
                        child: BlocBuilder<RatingCubit, RatingState>(
                          builder: (context, state) {
                            if (state is! RatingLoaded || state.count == 0) {
                              return const SizedBox.shrink();
                            }

                            final avgRating = state.avgRating;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: context.colors.warning,
                                  size: context.responsiveIconSize(18),
                                ),
                                SizedBox(width: context.spacingXs),
                                Text(
                                  avgRating.toStringAsFixed(1),
                                  style: context.typography.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.warning,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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
}
