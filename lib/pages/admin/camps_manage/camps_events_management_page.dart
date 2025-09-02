import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/event.dart';
import '../../../widgets/widgets.dart';

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
    if (!mounted) return;

    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    DateTime? selectedDateTime = event?.dateTime;
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    Future<void> pickDateTime(BuildContext dialogContext) async {
      final date = await showDatePicker(
        context: dialogContext,
        initialDate: selectedDateTime ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      );
      if (date == null || !dialogContext.mounted) return;

      final initialTime = selectedDateTime != null
          ? TimeOfDay(
        hour: selectedDateTime!.hour,
        minute: selectedDateTime!.minute,
      )
          : TimeOfDay.now();

      if (!dialogContext.mounted) return;
      final time = await showTimePicker(
        context: dialogContext,
        initialTime: initialTime,
      );
      if (time == null || !dialogContext.mounted) return;

      if (mounted) {
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
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            event == null ? 'Add Event' : 'Edit Event',
            style: MethodistTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: titleController,
                      label: 'Event Title',
                      hint: 'Enter event title',
                      textCapitalization: TextCapitalization.words,
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Title is required' : null,
                    ),

                    SizedBox(height: MethodistTheme.spacingM),

                    AppTextField(
                      controller: descriptionController,
                      label: 'Description',
                      hint: 'Enter event description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Description is required' : null,
                    ),

                    SizedBox(height: MethodistTheme.spacingM),

                    InkWell(
                      onTap: () async {
                        await pickDateTime(dialogContext);
                        setDialogState(() {});
                      },
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                      child: Container(
                        padding: MethodistTheme.paddingM,
                        decoration: BoxDecoration(
                          border: Border.all(color: MethodistTheme.mediumGray.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: MethodistTheme.primaryRed,
                              size: 20,
                            ),
                            SizedBox(width: MethodistTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date & Time',
                                    style: MethodistTheme.labelMedium.copyWith(
                                      color: MethodistTheme.mediumGray,
                                    ),
                                  ),
                                  SizedBox(height: MethodistTheme.spacingXS),
                                  Text(
                                    selectedDateTime == null
                                        ? 'Select Date & Time'
                                        : selectedDateTime!.toLocal().toString().split('.').first,
                                    style: MethodistTheme.bodyMedium.copyWith(
                                      color: selectedDateTime == null
                                          ? MethodistTheme.mediumGray
                                          : MethodistTheme.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            PrimaryButton.secondary(
              label: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            SizedBox(width: MethodistTheme.spacingS),
            PrimaryButton(
              label: event == null ? 'Add Event' : 'Update Event',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedDateTime == null) {
                  if (selectedDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select date and time'),
                        backgroundColor: MethodistTheme.errorRed,
                      ),
                    );
                  }
                  return;
                }

                setDialogState(() => loading = true);
                final navigator = Navigator.of(dialogContext);

                try {
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

                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            event == null ? 'Event added successfully' : 'Event updated successfully'
                        ),
                        backgroundColor: MethodistTheme.successGreen,
                      ),
                    );
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: MethodistTheme.errorRed,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setDialogState(() => loading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent(String eventId, String eventTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event', style: MethodistTheme.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$eventTitle"? This cannot be undone.',
          style: MethodistTheme.bodyMedium,
        ),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          SizedBox(width: MethodistTheme.spacingS),
          PrimaryButton.danger(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('camps')
          .doc(widget.campId)
          .collection('events')
          .doc(eventId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: MethodistTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: MethodistTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text('Manage Events - ${widget.campTitle}'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        tooltip: 'Add Event',
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CampEvent>>(
        stream: _getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading events...');
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading Events',
              description: 'Error: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event,
              title: 'No Events Found',
              description: 'No events have been created for this camp yet. Tap the + button to add the first event.',
            );
          }

          return ListView.builder(
            padding: MethodistTheme.paddingM,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final dateStr = event.dateTime.toLocal().toString().split('.').first;

              return InfoCard(
                title: event.title,
                subtitle: dateStr,
                description: event.description,
                icon: Icons.event,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: MethodistTheme.warningOrange,
                    ),
                    tooltip: 'Edit Event',
                    onPressed: () => _showEventDialog(event: event),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: MethodistTheme.errorRed,
                    ),
                    tooltip: 'Delete Event',
                    onPressed: () => _deleteEvent(event.id, event.title),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}