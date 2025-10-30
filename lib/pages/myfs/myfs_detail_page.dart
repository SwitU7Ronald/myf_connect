import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event.dart';
import '../../widgets/widgets.dart';
import '../../app/theme.dart';

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

  /// Get events stream based on upcoming/past filter
  Stream<List<MyfEvent>> _getEvents({required bool upcoming}) {
    final nowTs = Timestamp.now();
    final collection = FirebaseFirestore.instance
        .collection('myfs')
        .doc(widget.myfId)
        .collection('events');

    final query = upcoming
        ? collection
        .where('dateTime', isGreaterThanOrEqualTo: nowTs)
        .orderBy('dateTime')
        : collection
        .where('dateTime', isLessThan: nowTs)
        .orderBy('dateTime', descending: true);

    return query.snapshots().map(
          (snap) => snap.docs
          .map((doc) => MyfEvent.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Build event list widget for upcoming or past events
  Widget _buildEventList(bool upcoming) {
    return StreamBuilder<List<MyfEvent>>(
      stream: _getEvents(upcoming: upcoming),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading events...');
        }
        if (snapshot.hasError) {
          return ErrorStateWidget(
            title: 'Error loading events',
            description: 'Error: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return EmptyStateWidget(
            icon: upcoming ? Icons.upcoming : Icons.history,
            title: upcoming ? 'No Upcoming Events' : 'No Past Events',
            description: upcoming
                ? 'Check back later for upcoming events in this MYF group.'
                : 'No past events found for this MYF group.',
          );
        }

        return ListView.builder(
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
                showRating: !upcoming, // Show rating for past events only
                avgRating: event.avgRating,
                numRatings: event.numRatings,
                eventId: event.id,
                campOrMyfId: widget.myfId,
                isCamp: false,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text(
          widget.myfTitle,
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        // ✅ FIXED: Proper TabBar styling with visible text
        bottom: TabBar(
          controller: _tabController,
          labelColor: MethodistTheme.white,
          unselectedLabelColor: MethodistTheme.white.withValues(alpha: 0.7),
          indicatorColor: MethodistTheme.white,
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
                  Icon(
                    Icons.upcoming,
                    size: context.responsiveIconSize(18),
                  ),
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
                  Icon(
                    Icons.history,
                    size: context.responsiveIconSize(18),
                  ),
                  SizedBox(width: context.spacing(6)),
                  const Text('Past'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventList(true),
          _buildEventList(false),
        ],
      ),
    );
  }
}
