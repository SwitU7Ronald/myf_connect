import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widgets.dart';
import 'camps_detail_page.dart';

class CampsListPage extends StatelessWidget {
  const CampsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camps')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingWidget(message: 'Loading camps...');
          }

          final camps = snapshot.data!.docs;

          if (camps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.campaign,
              title: 'No Camps Available',
              description: 'Check back later for upcoming camps and events.',
            );
          }

          return ListView.builder(
            padding: MethodistTheme.paddingM,
            itemCount: camps.length,
            itemBuilder: (context, index) {
              final camp = camps[index];
              final campId = camp.id;
              final data = camp.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Unnamed Camp';
              final place = data['place'] ?? '';
              final description = data['description'] ?? '';

              // Parse date
              String dateStr = '';
              final dateVal = data['date'];
              if (dateVal is Timestamp) {
                dateStr = dateVal.toDate().toLocal().toString().split(' ').first;
              } else if (dateVal is String) {
                final parsedDate = DateTime.tryParse(dateVal);
                dateStr = parsedDate?.toLocal().toString().split(' ').first ?? '';
              }

              return InfoCard(
                title: title,
                subtitle: place.isNotEmpty ? place : null,
                description: '$dateStr${description.isNotEmpty ? '\n$description' : ''}',
                icon: Icons.campaign,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampsDetailPage(
                        campId: campId,
                        campTitle: title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}