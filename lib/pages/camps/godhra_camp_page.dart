import 'package:flutter/material.dart';
import 'camp_events_tab.dart';

class GodhraCampPage extends StatelessWidget {
  const GodhraCampPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Godhra Camp 2025'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'Past Events'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CampEventsTab(collectionPath: 'camps/godhra_camp_2025/events_upcoming'),
            CampEventsTab(collectionPath: 'camps/godhra_camp_2025/events_past'),
          ],
        ),
      ),
    );
  }
}
