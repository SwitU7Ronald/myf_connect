import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/events/presentation/cubit/events_cubit.dart';
import 'package:myf_connect/features/events/presentation/widgets/event_card.dart';

class MyfsDetailPage extends StatefulWidget {
  final String myfId;
  final String myfTitle;

  const MyfsDetailPage({
    super.key,
    required this.myfId,
    required this.myfTitle,
  });

  @override
  State<MyfsDetailPage> createState() => _MyfsDetailPageState();
}

class _MyfsDetailPageState extends State<MyfsDetailPage>
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
                  ? 'Check back later for upcoming events in this MYF group.'
                  : 'No past events found for this MYF group.',
            );
          }

          return ResponsiveConstrainedBox(
            child: ListView.builder(
              padding: context.responsivePadding(all: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: context.spacing(12)),
                  child: EventCard(
                    title: event.title,
                    description: event.description,
                    dateTime: event.dateTime,
                    venue: event.venue,
                    showRating: !upcoming,
                    avgRating: event.avgRating,
                    numRatings: event.numRatings,
                    eventId: event.id,
                    campOrMyfId: widget.myfId,
                    isCamp: false,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.myfTitle,
          style: context.responsiveHeadlineSmall.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(
            context,
          ).appBarTheme.foregroundColor?.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          labelStyle: TextStyle(
            fontSize: context.responsiveFontSize(14),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: context.responsiveFontSize(14),
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upcoming, size: context.responsiveIconSize(18)),
                  SizedBox(width: context.spacing(6)),
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
                  SizedBox(width: context.spacing(6)),
                  const Text('Past'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) => di.sl<EventsCubit>(
          param1: widget.myfId,
          param2: false,
        )..loadEvents(),
        child: TabBarView(
          controller: _tabController,
          children: [_buildEventList(true), _buildEventList(false)],
        ),
      ),
    );
  }
}
