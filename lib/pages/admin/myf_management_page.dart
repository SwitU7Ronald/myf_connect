import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myf_create_page.dart';

class MyfManagementPage extends StatelessWidget {
  const MyfManagementPage({super.key});

  Future<void> _navigateToCreateMyf(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyfCreatePage()),
    );
    // Optionally refresh UI after return
  }

  Future<void> _deleteMyf(String id) async {
    await FirebaseFirestore.instance.collection('myf').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MYF Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateMyf(context),
        tooltip: 'Add MYF',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('myf').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final myfDocs = snap.data!.docs;
          if (myfDocs.isEmpty) return const Center(child: Text('No MYF entries found'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: myfDocs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final myf = myfDocs[index];
              final data = myf.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMyf(myf.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
