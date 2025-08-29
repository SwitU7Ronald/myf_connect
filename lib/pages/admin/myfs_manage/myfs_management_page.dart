import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myfs_events_management_page.dart';
import 'myfs_create_page.dart';

class MyfsManagementPage extends StatelessWidget {
  const MyfsManagementPage({super.key});

  Future<void> _navigateToCreateMyf(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyfsCreatePage()),
    );
  }

  Future<void> _deleteMyf(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete MYF'),
        content: const Text('Are you sure you want to delete this MYF? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ); // confirm dialog [1][2]
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('myfs').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MYF deleted')),
      ); // snackbar [3]
    }
  }

  Future<void> _showEditMyfDialog(
      BuildContext context,
      String myfId,
      Map<String, dynamic> data,
      ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit MYF'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ), // validation [4]
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ), // validation [4]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await FirebaseFirestore.instance.collection('myfs').doc(myfId).update({
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
              }); // update [5]
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('MYF updated')),
              ); // snackbar [3]
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ); // dialog [1]
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
        stream: FirebaseFirestore.instance.collection('myfs').snapshots(), // realtime [5]
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
              final myfId = myf.id;

              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Edit MYF',
                      onPressed: () => _showEditMyfDialog(context, myfId, data), // edit [1]
                    ),
                    IconButton(
                      icon: const Icon(Icons.event, color: Colors.blue),
                      tooltip: 'Manage Events',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyfsEventsManagementPage(
                              myfId: myfId,
                              myfTitle: data['title'] ?? 'MYF',
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete MYF',
                      onPressed: () => _deleteMyf(context, myfId), // confirm + delete [1]
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
