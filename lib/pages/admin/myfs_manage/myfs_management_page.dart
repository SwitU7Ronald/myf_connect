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
    if (!context.mounted) return;
  }

  Future<void> _deleteMyf(BuildContext context, String id) async {
    debugPrint('[MYF Delete] Starting deletion of MYF: $id');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete MYF'),
        content: const Text(
          'Are you sure you want to delete this MYF and all its events? This cannot be undone.',
        ),
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
    );

    if (confirmed != true) {
      debugPrint('[MYF Delete] Deletion cancelled by user');
      return;
    }

    // Show loading overlay
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => const Stack(
        children: [
          ModalBarrier(dismissible: false, color: Colors.black38),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
    overlay.insert(entry);

    try {
      // 1. Fetch all events from the subcollection for this MYF
      final eventsRef = FirebaseFirestore.instance
          .collection('myfs')
          .doc(id)
          .collection('events');

      const pageSize = 250; // Safe batch size
      while (true) {
        final page = await eventsRef
            .orderBy(FieldPath.documentId)
            .limit(pageSize)
            .get(const GetOptions(source: Source.server)); // Force fresh read

        if (page.docs.isEmpty) break;

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in page.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 2. Delete the MYF itself
      await FirebaseFirestore.instance.collection('myfs').doc(id).delete();

      // 3. Notify user
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MYF and all events deleted')),
      );
    } catch (e, stack) {
      debugPrint('[MYF Delete] FAILED to delete MYF: $e');
      debugPrint('[MYF Delete] Stack trace: $stack');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      entry.remove();
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
                  validator: (v) {
                    return v == null || v.trim().isEmpty ? 'Required' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) {
                    return v == null || v.trim().isEmpty ? 'Required' : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await FirebaseFirestore.instance
                    .collection('myfs')
                    .doc(myfId)
                    .update({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('MYF updated')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
        stream: FirebaseFirestore.instance.collection('myfs').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final myfDocs = snap.data!.docs;
          if (myfDocs.isEmpty) {
            return const Center(child: Text('No MYF entries found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: myfDocs.length,
            separatorBuilder: (context, index) => const Divider(),
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
                      onPressed: () => _showEditMyfDialog(context, myfId, data),
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
                      onPressed: () => _deleteMyf(context, myfId),
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
