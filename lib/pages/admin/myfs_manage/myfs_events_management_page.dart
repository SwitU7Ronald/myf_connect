import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyfsEventsManagementPage extends StatefulWidget {
  final String myfId;
  final String myfTitle;

  const MyfsEventsManagementPage({
    super.key,
    required this.myfId,
    required this.myfTitle,
  });

  @override
  State<MyfsEventsManagementPage> createState() =>
      _MyfsEventsManagementPageState();
}

class _MyfsEventsManagementPageState extends State<MyfsEventsManagementPage> {
  Stream<QuerySnapshot<Map<String, dynamic>>> _eventsStream() {
    return FirebaseFirestore.instance
        .collection('myfs')
        .doc(widget.myfId)
        .collection('events')
        .orderBy('dateTime')
        .snapshots();
  }

  Future<void> _showEventDialog({
    DocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final navigator = Navigator.of(context);

    final titleCtrl = TextEditingController(text: doc?.data()?['title'] ?? '');
    final descCtrl = TextEditingController(
      text: doc?.data()?['description'] ?? '',
    );

    DateTime? selected = () {
      final raw = doc?.data()?['dateTime'];
      if (raw == null) return null;
      if (raw is String) return DateTime.tryParse(raw);
      if (raw is Timestamp) return raw.toDate();
      return null;
    }();

    final formKey = GlobalKey<FormState>();

    Future<void> pickDateTime() async {
      final now = DateTime.now();

      final date = await showDatePicker(
        context: context,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now.add(const Duration(days: 365 * 2)),
        initialDate: selected ?? now,
      );
      if (date == null) return;

      if (!mounted) return;

      final time = await showTimePicker(
        context: context,
        initialTime: selected != null
            ? TimeOfDay(hour: selected!.hour, minute: selected!.minute)
            : TimeOfDay.now(),
      );
      if (time == null) return;

      if (!mounted) return;
      setState(() {
        selected = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Add MYF Event' : 'Edit MYF Event'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    selected == null
                        ? 'Select date & time'
                        : selected!.toLocal().toString(),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDateTime,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate() || selected == null) {
                return;
              }

              final col = FirebaseFirestore.instance
                  .collection('myfs')
                  .doc(widget.myfId)
                  .collection('events');

              final payload = {
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'dateTime': selected!.toIso8601String(),
              };

              if (doc == null) {
                await col.add(payload);
              } else {
                await col.doc(doc.id).update(payload);
              }

              if (!mounted) return;
              navigator.pop();
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('myfs')
          .doc(widget.myfId)
          .collection('events')
          .doc(id)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Events - ${widget.myfTitle}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _eventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              final raw = data['dateTime'];
              DateTime? dt;
              if (raw is String) dt = DateTime.tryParse(raw);
              if (raw is Timestamp) dt = raw.toDate();

              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(
                  '${dt != null ? dt.toLocal().toString().split(" ").first : ""}\n${data['description'] ?? ""}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEventDialog(doc: d),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(d.id),
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
