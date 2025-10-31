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
        .map((snapshot) => snapshot.docs
        .map((doc) => CampEvent.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> _showEventDialog({CampEvent? event}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController =
    TextEditingController(text: event?.description ?? '');
    final venueController = TextEditingController(text: event?.venue ?? '');

    DateTime? selectedDateTime = event?.dateTime;
    bool loading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            event == null ? 'Add Event' : 'Edit Event',
            // ✅ RESPONSIVE: Use responsive text style
            style: context.responsiveHeadlineSmall,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              // ✅ RESPONSIVE: Make dialog width responsive
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event Title Field
                    AppTextField(
                      controller: titleController,
                      label: 'Event Title',
                      hint: 'Enter event title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    // ✅ RESPONSIVE: Use context.spacing
                    SizedBox(height: context.spacing(16)),

                    // Event Venue Field
                    AppTextField(
                      controller: venueController,
                      label: 'Venue',
                      hint: 'Enter event venue',
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: context.spacing(16)),

                    // Event Description Field
                    AppTextField(
                      controller: descriptionController,
                      label: 'Description',
                      hint: 'Enter event description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    SizedBox(height: context.spacing(16)),

                    // Event Date & Time Picker
                    DatePickerField.dateTime(
                      selectedDateTime: selectedDateTime,
                      label: 'Event Date & Time',
                      hint: 'Select date and time',
                      firstDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      onDateTimeSelected: (dateTime) {
                        setDialogState(() => selectedDateTime = dateTime);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: context.responsivePadding(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            PrimaryButton.secondary(
              label: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            SizedBox(width: context.spacing(8)),
            PrimaryButton(
              label: event == null ? 'Add Event' : 'Update Event',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() ||
                    selectedDateTime == null) {
                  if (selectedDateTime == null) {
                    MethodistTheme.showErrorSnackBar(
                        context, 'Please select date and time');
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
                      event == null
                          ? 'Event added successfully'
                          : 'Event updated successfully',
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
    // ✅ RESPONSIVE: Delete confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Event',
          // ✅ RESPONSIVE: Use responsive text style
          style: context.responsiveHeadlineSmall,
        ),
        content: Text(
          'Are you sure you want to delete "$eventTitle"? This cannot be undone.',
          // ✅ RESPONSIVE: Use responsive text style
          style: context.responsiveBodyMedium,
        ),
        actionsPadding: context.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          SizedBox(width: context.spacing(8)),
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
        MethodistTheme.showSuccessSnackBar(
            context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(
            context, 'Error deleting event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Manage Events - ${widget.campTitle}',
          // ✅ RESPONSIVE: Use responsive text style
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        tooltip: 'Add Event',
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        // ✅ RESPONSIVE: Use responsive icon size
        child: Icon(
          Icons.add,
          size: context.responsiveIconSize(28),
        ),
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
              description:
              'No events have been created for this camp yet. Tap the + button to add the first event.',
            );
          }

          return ListView.builder(
            // ✅ RESPONSIVE: Use context.responsivePadding
            padding: context.responsivePadding(all: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final dateStr =
                  event.dateTime.toLocal().toString().split('.').first;

              return Column(
                children: [
                  InfoCard(
                    title: event.title,
                    subtitle: dateStr,
                    description: event.description,
                    icon: Icons.event,
                    actions: [
                      // Edit Button - ✅ RESPONSIVE
                      Tooltip(
                        message: 'Edit Event',
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: MethodistTheme.warningOrange,
                            // ✅ RESPONSIVE: Use responsive icon size
                            size: context.responsiveIconSize(20),
                          ),
                          onPressed: () =>
                              _showEventDialog(event: event),
                        ),
                      ),
                      // Delete Button - ✅ RESPONSIVE
                      Tooltip(
                        message: 'Delete Event',
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: MethodistTheme.errorRed,
                            size: context.responsiveIconSize(20),
                          ),
                          onPressed: () =>
                              _deleteEvent(event.id, event.title),
                        ),
                      ),
                    ],
                  ),
                  // ✅ RESPONSIVE: Use context.spacing between items
                  if (index < events.length - 1)
                    SizedBox(height: context.spacing(12)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
