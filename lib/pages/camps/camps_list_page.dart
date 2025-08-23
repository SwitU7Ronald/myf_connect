import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampsListPage extends StatelessWidget {
  const CampsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final campsStream = FirebaseFirestore.instance
        .collection('camps')
        .orderBy('date')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: campsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No camps found'));
        }

        final camps = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: camps.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final camp = camps[index];
            final data = camp.data() as Map<String, dynamic>;

            final title = data['title'] ?? 'Untitled Camp';
            final date = data['date'] ?? '';
            final place = data['place'] ?? '';
            final description = data['description'] ?? '';

            return ListTile(
              title: Text(title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: $date'),
                  Text('Place: $place'),
                  if (description.isNotEmpty) Text('Description: $description'),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                // TODO: Navigate to detailed camp page or events if needed
              },
            );
          },
        );
      },
    );
  }
}
