import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyfManagementPage extends StatelessWidget {
  const MyfManagementPage({super.key});

  Future<void> _createMYF() async {
    await FirebaseFirestore.instance.collection("myf").add({
      "title": "New MYF",
      "description": "MYF description",
    });
  }

  Future<void> _deleteMYF(String id) async {
    await FirebaseFirestore.instance.collection("myf").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MYF Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMYF,
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
              return ListTile(
                title: Text(myf['title']),
                subtitle: Text(myf['description']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMYF(myf.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
