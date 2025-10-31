import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';

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
    final titleCtrl =
    TextEditingController(text: doc?.data()?['title'] ?? '');
    final descCtrl = TextEditingController(
      text: doc?.data()?['description'] ?? '',
    );

    DateTime? selected;
    final raw = doc?.data()?['dateTime'];
    if (raw is String) selected = DateTime.tryParse(raw);
    if (raw is Timestamp) selected = raw.toDate();

    final formKey = GlobalKey<FormState>();
    bool loading = false;

    Future<void> pickDateTime(BuildContext dialogContext) async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: dialogContext,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now.add(const Duration(days: 730)),
        initialDate: selected ?? now,
      );
      if (date == null || !dialogContext.mounted) return;

      final time = await showTimePicker(
        context: dialogContext,
        initialTime: (selected != null)
            ? TimeOfDay(hour: selected!.hour, minute: selected!.minute)
            : TimeOfDay.now(),
      );
      if (time == null || !dialogContext.mounted) return;

      if (mounted) {
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
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              doc == null ? 'Add MYF Event' : 'Edit MYF Event',
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
                        controller: titleCtrl,
                        label: 'Event Title',
                        hint: 'Enter event title',
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),

                      // ✅ RESPONSIVE: Use context.spacing
                      SizedBox(height: context.spacing(16)),

                      // Event Description Field
                      AppTextField(
                        controller: descCtrl,
                        label: 'Description',
                        hint: 'Enter event description',
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Description is required'
                            : null,
                      ),

                      SizedBox(height: context.spacing(16)),

                      // Date & Time Picker - ✅ RESPONSIVE
                      InkWell(
                        onTap: () async {
                          await pickDateTime(dialogContext);
                          setDialogState(() {});
                        },
                        borderRadius: BorderRadius.circular(
                          context.responsiveRadius(12),
                        ),
                        child: Container(
                          padding: context.responsivePadding(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MethodistTheme.mediumGray
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(
                              context.responsiveRadius(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: MethodistTheme.primaryRed,
                                // ✅ RESPONSIVE: Use responsive icon size
                                size: context.responsiveIconSize(20),
                              ),
                              SizedBox(width: context.spacing(16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date & Time',
                                      style: context
                                          .responsiveLabelMedium
                                          .copyWith(
                                        color: MethodistTheme.mediumGray,
                                      ),
                                    ),
                                    SizedBox(
                                      height: context.spacing(4),
                                    ),
                                    Text(
                                      selected == null
                                          ? 'Select date & time'
                                          : selected!
                                          .toLocal()
                                          .toString()
                                          .split('.')
                                          .first,
                                      style: context
                                          .responsiveBodyMedium
                                          .copyWith(
                                        color: selected == null
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
            actionsPadding: context.responsivePadding(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              PrimaryButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              SizedBox(width: context.spacing(8)),
              PrimaryButton(
                label: doc == null ? 'Add Event' : 'Update Event',
                loading: loading,
                onPressed: () async {
                  if (!formKey.currentState!.validate() || selected == null) {
                    if (selected == null) {
                      MethodistTheme.showErrorSnackBar(
                          context, 'Please select date and time');
                    }
                    return;
                  }

                  setDialogState(() => loading = true);

                  try {
                    final col = FirebaseFirestore.instance
                        .collection('myfs')
                        .doc(widget.myfId)
                        .collection('events');

                    final payload = {
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'dateTime': Timestamp.fromDate(selected!),
                    };

                    if (doc == null) {
                      await col.add(payload);
                    } else {
                      await col.doc(doc.id).update(payload);
                    }

                    if (dialogContext.mounted) {
                      MethodistTheme.showSuccessSnackBar(
                        context,
                        doc == null
                            ? 'Event added successfully'
                            : 'Event updated successfully',
                      );
                      Navigator.of(dialogContext).pop();
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
        );
      },
    );
  }

  Future<void> _handleDeleteEvent(String id, String title) async {
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
          'Are you sure you want to delete "$title"? This cannot be undone.',
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
          .collection('myfs')
          .doc(widget.myfId)
          .collection('events')
          .doc(id)
          .delete();

      if (mounted) {
        MethodistTheme.showSuccessSnackBar(
            context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(
            context, 'Failed to delete event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Manage Events - ${widget.myfTitle}',
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _eventsStream(),
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

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event,
              title: 'No Events Found',
              description:
              'No events have been created for this MYF group yet. Tap the + button to add the first event.',
            );
          }

          return ListView.builder(
            // ✅ RESPONSIVE: Use context.responsivePadding
            padding: context.responsivePadding(all: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data();
              final raw = data['dateTime'];

              DateTime? dt;
              if (raw is String) dt = DateTime.tryParse(raw);
              if (raw is Timestamp) dt = raw.toDate();

              return Column(
                children: [
                  InfoCard(
                    title: data['title'] ?? 'Untitled Event',
                    subtitle: dt != null
                        ? dt.toLocal().toString().split(' ').first
                        : 'No date set',
                    description: data['description'] ?? 'No description',
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
                              _showEventDialog(doc: d),
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
                          onPressed: () => _handleDeleteEvent(
                              d.id, data['title'] ?? 'Untitled Event'),
                        ),
                      ),
                    ],
                  ),
                  // ✅ RESPONSIVE: Use context.spacing between items
                  if (index < docs.length - 1)
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
