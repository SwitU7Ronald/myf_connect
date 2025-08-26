import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';

class CampDetailPage extends StatefulWidget {
  final String campId;
  final String campTitle;

  const CampDetailPage({super.key, required this.campId, required this.campTitle});

  @override
  State<CampDetailPage> createState() => _CampDetailPageState();
}

class _CampDetailPageState extends State<CampDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Stream<List<CampEvent>> _getEvents({required bool upcoming}) {
    final nowIso = DateTime.now().toIso8601String();
    final collection = FirebaseFirestore.instance
        .collection('camps')
        .doc(widget.campId)
        .collection('events');

    final query = upcoming
        ? collection.where('dateTime', isGreaterThanOrEqualTo: nowIso).orderBy('dateTime')
        : collection.where('dateTime', isLessThan: nowIso).orderBy('dateTime', descending: true);

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => CampEvent.fromMap(doc.id, doc.data())).toList()
    );
  }

  Widget _buildEventList(bool upcoming) {
    return StreamBuilder<List<CampEvent>>(
      stream: _getEvents(upcoming: upcoming),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(child: Text(upcoming ? 'No upcoming events' : 'No past events'));

        final events = snapshot.data!;
        return ListView.separated(
          itemCount: events.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final ev = events[index];
            return ListTile(
              title: Text(ev.title),
              subtitle: Text('${ev.dayOfWeek}, ${ev.dateTime.toLocal().toString().split(' ')[0]}'
                  '\n${ev.description}'),
              isThreeLine: true,
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
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Past Events'),
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
