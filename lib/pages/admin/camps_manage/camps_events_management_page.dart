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
  State<CampsEventsManagementPage> createState() => _CampsEventsManagementPageState();
}

class _CampsEventsManagementPageState extends State<CampsEventsManagementPage> {
  Stream<List<CampEvent>> _getEvents() {
    return FirebaseFirestore.instance
        .collection('camps')
        .doc(widget.campId)
        .collection('events')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CampEvent.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> _showEventDialog({CampEvent? event}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final venueController = TextEditingController(text: event?.venue ?? '');

    DateTime? selectedDateTime = event?.dateTime;
    bool loading = false;

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
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    AppTextField(
                      controller: venueController,
                      label: 'Venue',
                      hint: 'Enter event venue',
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    AppTextField(
                      controller: descriptionController,
                      label: 'Description',
                      hint: 'Enter event description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),

                    // UPDATED: Use new DatePickerField.dateTime
                    DatePickerField.dateTime(
                      selectedDateTime: selectedDateTime,
                      label: 'Event Date & Time',
                      hint: 'Select date and time',
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      onDateTimeSelected: (dateTime) {
                        setDialogState(() => selectedDateTime = dateTime);
                      },
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
                    MethodistTheme.showErrorSnackBar(context, 'Please select date and time');
                  }
                  return;
                }

                setDialogState(() => loading = true);
                final navigator = Navigator.of(context);

                try {
                  final eventData = {
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'venue': venueController.text.trim(),
                    'dateTime': Timestamp.fromDate(selectedDateTime!),
                  };

                  if (event == null) {
                    await FirebaseFirestore.instance
                        .collection('camps')
                        .doc(widget.campId)
                        .collection('events')
                        .add(eventData);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('camps')
                        .doc(widget.campId)
                        .collection('events')
                        .doc(event.id)
                        .update(eventData);
                  }

                  if (dialogContext.mounted) {
                    MethodistTheme.showSuccessSnackBar(
                        context,
                        event == null ? 'Event added successfully' : 'Event updated successfully'
                    );
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    MethodistTheme.showErrorSnackBar(context, 'Error: $e');
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
        MethodistTheme.showSuccessSnackBar(context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Error deleting event: $e');
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
