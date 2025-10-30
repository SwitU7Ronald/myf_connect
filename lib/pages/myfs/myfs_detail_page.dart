import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widgets.dart';

class MyfEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;
  final String? venue;
  final double avgRating;
  final int numRatings;

  MyfEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
    this.venue,
    this.avgRating = 0.0,
    this.numRatings = 0,
  });

  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];

  factory MyfEvent.fromMap(String id, Map<String, dynamic> data) {
    final raw = data['dateTime'];
    final dt = raw is Timestamp ? raw.toDate() : DateTime.parse(raw as String);
    return MyfEvent(
      id: id,
      dateTime: dt,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      venue: data['venue'],
      avgRating: (data['avgRating'] ?? 0.0).toDouble(),
      numRatings: data['numRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'title': title,
      'description': description,
      if (venue != null) 'venue': venue,
      'avgRating': avgRating,
      'numRatings': numRatings,
    };
  }
}

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
    with SingleTickerProviderStateMixin {
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
            title: 'Error Loading Events',
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
          padding: MethodistTheme.paddingM,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: EdgeInsets.only(bottom: MethodistTheme.spacingM),
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
                isCamp: false, // This is MYF, not camp
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
      appBar: AppBar(
        title: Text(widget.myfTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.upcoming)),
            Tab(text: 'Past', icon: Icon(Icons.history)),
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
