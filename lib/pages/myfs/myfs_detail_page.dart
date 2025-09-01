import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyfEvent {
  final String id;
  final DateTime dateTime;
  final String title;
  final String description;

  MyfEvent({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.description,
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
    );
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

  Stream<List<MyfEvent>> _getEvents({required bool upcoming}) {
    final nowIso = DateTime.now().toIso8601String();
    final collection = FirebaseFirestore.instance
        .collection('myfs')
        .doc(widget.myfId)
        .collection('events');

    final query = upcoming
        ? collection
              .where('dateTime', isGreaterThanOrEqualTo: nowIso)
              .orderBy('dateTime')
        : collection
              .where('dateTime', isLessThan: nowIso)
              .orderBy('dateTime', descending: true);

    return query.snapshots().map(
      (snap) =>
          snap.docs.map((doc) => MyfEvent.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Widget _buildEventList(bool upcoming) {
    return StreamBuilder<List<MyfEvent>>(
      stream: _getEvents(upcoming: upcoming),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(upcoming ? 'No upcoming events' : 'No past events'),
          );
        }

        final events = snapshot.data!;
        return ListView.separated(
          itemCount: events.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final ev = events[index];
            return ListTile(
              title: Text(ev.title),
              subtitle: Text(
                '${ev.dayOfWeek}, ${ev.dateTime.toLocal().toString().split(' ')[0]}\n${ev.description}',
              ),
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
        title: Text(widget.myfTitle),
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
        children: [_buildEventList(true), _buildEventList(false)],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
