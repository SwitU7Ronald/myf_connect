import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/blocs/events/events_cubit.dart';
import 'package:myf_connect/core/widgets/event_card.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class CampsDetailPage extends StatefulWidget {
  final String campId;
  final String campTitle;

  const CampsDetailPage({
    super.key,
    required this.campId,
    required this.campTitle,
  });

  @override
  State<CampsDetailPage> createState() => _CampsDetailPageState();
}

class _CampsDetailPageState extends State<CampsDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEventList(bool upcoming) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading || state is EventsInitial) {
          return const LoadingWidget(message: 'Loading events...');
        }
        if (state is EventsError) {
          return ErrorStateWidget(
            title: 'Error loading events',
            description: 'Error: ${state.message}',
            onRetry: () => context.read<EventsCubit>().loadEvents(),
          );
        }

        if (state is EventsLoaded) {
          final events = upcoming ? state.upcomingEvents : state.pastEvents;
          if (events.isEmpty) {
            return EmptyStateWidget(
              icon: upcoming ? Icons.upcoming : Icons.history,
              title: upcoming ? 'No Upcoming Events' : 'No Past Events',
              description: upcoming
                  ? 'Check back later for upcoming events in this camp.'
                  : 'No past events found for this camp.',
            );
          }

          return ResponsiveConstrainedBox(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacingMd,
                vertical: context.spacingMd,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: context.spacingMd),
                  child: EventCard(
                    title: event.title,
                    description: event.description,
                    dateTime: event.dateTime,
                    venue: event.venue,
                    showRating: !upcoming,
                    avgRating: event.avgRating,
                    numRatings: event.numRatings,
                    eventId: event.id,
                    campOrMyfId: widget.campId,
                    isCamp: true,
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<EventsCubit>(param1: widget.campId, param2: true)
            ..loadEvents(),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 60),
                  title: Text(
                    widget.campTitle,
                    style: context.typography.titleLarge!.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.colors.primary,
                              context.colors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Icon(
                          Icons.campaign,
                          size: 200,
                          color: context.colors.surface.withValues(alpha: 0.07),
                        ),
                      ),
                      // Bottom scrim for text readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: ColoredBox(
                    color: context.colors.surface,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: context.colors.primary,
                      unselectedLabelColor: context.colors.textSecondary,
                      indicatorColor: context.colors.primary,
                      indicatorWeight: 3,
                      labelStyle: context.typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: context.typography.titleMedium,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upcoming, size: context.responsiveIconSize(18)),
                              SizedBox(width: context.spacingSm),
                              const Text('Upcoming'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history, size: context.responsiveIconSize(18)),
                              SizedBox(width: context.spacingSm),
                              const Text('Past'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [_buildEventList(true), _buildEventList(false)],
          ),
        ),
      ),
    );
  }
}
