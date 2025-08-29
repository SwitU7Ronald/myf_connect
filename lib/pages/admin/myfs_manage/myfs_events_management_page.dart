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
  State<MyfsEventsManagementPage> createState() => _MyfsEventsManagementPageState();
}

class _MyfsEventsManagementPageState extends State<MyfsEventsManagementPage> {
  // Stream MYF events ordered by dateTime (ISO string or Timestamp both work)
  Stream<QuerySnapshot<Map<String, dynamic>>> _eventsStream() {
    return FirebaseFirestore.instance
        .collection('myfs')
        .doc(widget.myfId)
        .collection('events')
        .orderBy('dateTime')
        .snapshots(); // realtime updates [8]
  }

  Future<void> _showEventDialog({DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final titleCtrl = TextEditingController(text: doc?.data()?['title'] ?? '');
    final descCtrl = TextEditingController(text: doc?.data()?['description'] ?? '');

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

      final time = await showTimePicker(
        context: context,
        initialTime: selected != null
            ? TimeOfDay(hour: selected!.hour, minute: selected!.minute)
            : TimeOfDay.now(),
      );
      if (time == null) return;

      setState(() {
        selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, // validation [6]
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, // validation [6]
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(selected == null ? 'Select date & time' : selected!.toLocal().toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDateTime,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate() || selected == null) return; // validate [6]

              final col = FirebaseFirestore.instance
                  .collection('myfs').doc(widget.myfId).collection('events');

              // Choose storage format:
              // A) ISO string (compatible with your Camps page)
              final payload = {
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'dateTime': selected!.toIso8601String(),
              };

              // B) Or Firestore Timestamp (recommended for range queries)
              // final payload = {
              //   'title': titleCtrl.text.trim(),
              //   'description': descCtrl.text.trim(),
              //   'dateTime': Timestamp.fromDate(selected!),
              // };

              if (doc == null) {
                await col.add(payload); // Create [8][1]
              } else {
                await col.doc(doc.id).update(payload); // Update [8][1]
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(String id) async {
    await FirebaseFirestore.instance
        .collection('myfs').doc(widget.myfId)
        .collection('events').doc(id)
        .delete(); // Delete [8][1]
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
        stream: _eventsStream(), // snapshots in realtime [8]
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // loading [8]
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No events found')); // empty [8]
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
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
