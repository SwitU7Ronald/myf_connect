import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CampEventsTab extends StatelessWidget {
  final String collectionPath;
  const CampEventsTab({super.key, required this.collectionPath});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection(collectionPath).orderBy('dateTime');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No events'));
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final dt = DateTime.tryParse(d['dateTime'] ?? '') ?? DateTime.now();
            final date = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
            final time = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
            final day = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][dt.weekday-1];
            return ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(date, style: const TextStyle(fontSize: 12)),
                ],
              ),
              title: Text(d['title'] ?? ''),
              subtitle: Text(d['description'] ?? ''),
              trailing: Text(time),
            );
          },
        );
      },
    );
  }
}
