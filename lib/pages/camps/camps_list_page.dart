import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../camps/camp_detail_page.dart';

class CampsListPage extends StatelessWidget {
  const CampsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camps')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('camps').orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final camps = snapshot.data!.docs;
          if (camps.isEmpty) return const Center(child: Text('No camps available'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: camps.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final camp = camps[index];
              final campId = camp.id;
              final title = camp['title'] ?? 'Unnamed Camp';

              return ListTile(
                title: Text(title),
                subtitle: Text('${camp['date'] ?? ''} • ${camp['place'] ?? ''}'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CampDetailPage(campId: campId, campTitle: title),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
