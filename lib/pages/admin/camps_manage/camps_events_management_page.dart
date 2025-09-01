import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/event.dart';

class CampsEventsManagementPage extends StatefulWidget {
  final String campId;
  final String campTitle;

  const CampsEventsManagementPage({
    super.key,
    required this.campId,
    required this.campTitle,
  });

  @override
  State<CampsEventsManagementPage> createState() =>
      _CampsEventsManagementPageState();
}

class _CampsEventsManagementPageState extends State<CampsEventsManagementPage> {
  Stream<List<CampEvent>> _getEvents() {
    return FirebaseFirestore.instance
        .collection('camps')
        .doc(widget.campId)
        .collection('events')
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snap) => snap.docs
          .map((doc) => CampEvent.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> _showEventDialog({CampEvent? event}) async {
    final navigator = Navigator.of(context);

    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    DateTime? selectedDateTime = event?.dateTime;

    final formKey = GlobalKey<FormState>();

    Future<void> pickDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDateTime ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      );
      if (date == null) {
        return;
      }

      if (!mounted) return;

      final initialTime = selectedDateTime != null
          ? TimeOfDay(
        hour: selectedDateTime!.hour,
        minute: selectedDateTime!.minute,
      )
          : TimeOfDay.now();

      final time = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (time == null) {
        return;
      }

      if (!mounted) return;
      setState(() {
        selectedDateTime = DateTime(
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
        title: Text(event == null ? 'Add Event' : 'Edit Event'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    selectedDateTime == null
                        ? 'Select Date & Time'
                        : selectedDateTime!.toLocal().toString(),
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
              if (!formKey.currentState!.validate() ||
                  selectedDateTime == null) {
                return;
              }
              final eventsCollection = FirebaseFirestore.instance
                  .collection('camps')
                  .doc(widget.campId)
                  .collection('events');

              final payload = {
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'dateTime': Timestamp.fromDate(selectedDateTime!),
              };

              if (event == null) {
                await eventsCollection.add(payload);
              } else {
                await eventsCollection.doc(event.id).update(payload);
              }

              if (!mounted) return;
              navigator.pop();
            },
            child: Text(event == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance
        .collection('camps')
        .doc(widget.campId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Events - ${widget.campTitle}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CampEvent>>(
        stream: _getEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text('No events found'));
          }
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final ev = events[index];
              return ListTile(
                title: Text(ev.title),
                subtitle: Text(
                  '${ev.dayOfWeek}, ${ev.dateTime.toLocal().toString().split(' ')}\n${ev.description}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEventDialog(event: ev),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(ev.id),
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
