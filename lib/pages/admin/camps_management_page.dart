import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_create_page.dart';  // Make sure this file exists in the same folder

class CampsManagementPage extends StatelessWidget {
  const CampsManagementPage({super.key});

  Future<void> _navigateToCreateCamp(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CampCreatePage()),
    );
    // Optionally, refresh state or UI here if needed after returning
  }

  Future<void> _deleteCamp(String id) async {
    await FirebaseFirestore.instance.collection("camps").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camps Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCamp(context),
        tooltip: 'Add Camp',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('camps').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final camps = snap.data!.docs;
          if (camps.isEmpty) return const Center(child: Text('No camps found'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: camps.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final camp = camps[index];
              return ListTile(
                title: Text(camp['title'] ?? 'Unnamed'),
                subtitle: Text(camp['date'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCamp(camp.id),
                ),
                onTap: () {
                  // TODO: Open event management for this camp
                },
              );
            },
          );
        },
      ),
    );
  }
}
