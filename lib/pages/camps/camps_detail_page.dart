import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';

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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading events...'),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading events: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  upcoming ? Icons.upcoming : Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  upcoming ? 'No upcoming events' : 'No past events',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final event = events[index];
            final dateStr = event.dateTime.toLocal().toString().split(' ');
            final date = dateStr.first;
            final time = dateStr.length > 1 ? dateStr[1].substring(0, 5) : '';
            return Card(
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text('${event.dayOfWeek}, $date'),
                        if (time.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(time),
                        ],
                      ],
                    ),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
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
        title: Text(widget.campTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Events', icon: Icon(Icons.upcoming)),
            Tab(text: 'Past Events', icon: Icon(Icons.history)),
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
