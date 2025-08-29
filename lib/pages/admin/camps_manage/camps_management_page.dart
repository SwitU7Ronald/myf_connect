import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camps_create_page.dart';
import './camps_events_management_page.dart';

class CampsManagementPage extends StatelessWidget {
  const CampsManagementPage({super.key});

  Future<void> _navigateToCreateCamp(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CampsCreatePage()),
    );
    if (!context.mounted) {
      return;
    }
  }

  Future<void> _deleteCamp(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Camp'),
        content: const Text(
          'Are you sure you want to delete this camp? This cannot be undone.',
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
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('camps').doc(id).delete();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camp deleted')));
    }
  }

  Future<void> _showEditCampDialog(
    BuildContext context,
    String campId,
    Map<String, dynamic> data,
  ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final placeCtrl = TextEditingController(text: data['place'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');
    // Stored as ISO string in this app
    DateTime? selectedDate = () {
      final raw = data['date'];
      if (raw is String) {
        return DateTime.tryParse(raw);
      }
      return null;
    }();

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
        initialDate: selectedDate ?? now,
      );
      if (picked != null) {
        selectedDate = picked;
      }
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Camp'),
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
                  controller: placeCtrl,
                  decoration: const InputDecoration(labelText: 'Place'),
                  validator: (v) {
                    return v == null || v.trim().isEmpty ? 'Required' : null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : selectedDate!.toLocal().toString().split(' ').first,
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDate,
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
              if (!formKey.currentState!.validate() || selectedDate == null) {
                return; // braces fix
              }
              await FirebaseFirestore.instance
                  .collection('camps')
                  .doc(campId)
                  .update({
                    'title': titleCtrl.text.trim(),
                    'place': placeCtrl.text.trim(),
                    'date': selectedDate!.toIso8601String(),
                    'description': descCtrl.text.trim(),
                  });
              if (!context.mounted) {
                return; // guard both calls below
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Camp updated')));
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
      appBar: AppBar(title: const Text('Camps Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCamp(context),
        tooltip: 'Add Camp',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('date')
            .snapshots(), // realtime
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final camps = snap.data!.docs;
          if (camps.isEmpty) {
            return const Center(child: Text('No camps found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: camps.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final camp = camps[index];
              final campId = camp.id;
              final data = camp.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Unnamed Camp';
              final dateIso = data['date'] ?? '';
              final dateShort = dateIso is String && dateIso.isNotEmpty
                  ? (DateTime.tryParse(
                          dateIso,
                        )?.toLocal().toString().split(' ').first ??
                        dateIso)
                  : '';

              return ListTile(
                title: Text(title),
                subtitle: Text(dateShort),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Edit Camp',
                      onPressed: () =>
                          _showEditCampDialog(context, campId, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.event, color: Colors.blue),
                      tooltip: 'Manage Events',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CampsEventsManagementPage(
                              campId: campId,
                              campTitle: title,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Camp',
                      onPressed: () => _deleteCamp(context, campId),
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
