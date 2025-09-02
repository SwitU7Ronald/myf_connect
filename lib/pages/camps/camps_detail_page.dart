import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';
import '../../widgets/widgets.dart';

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Stream<List<CampEvent>> _getEvents({required bool upcoming}) {
    final nowTs = Timestamp.now();
    final collection = FirebaseFirestore.instance
        .collection('camps')
        .doc(widget.campId)
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
          .map((doc) => CampEvent.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Widget _buildEventList(bool upcoming) {
    return StreamBuilder<List<CampEvent>>(
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
                ? 'Check back later for upcoming events in this camp.'
                : 'No past events found for this camp.',
          );
        }

        return ListView.builder(
          padding: MethodistTheme.paddingM,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              title: event.title,
              description: event.description,
              dateTime: event.dateTime,
              showRating: !upcoming, // Show rating for past events only
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
        title: Text(widget.campTitle),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}