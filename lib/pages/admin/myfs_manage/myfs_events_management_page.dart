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
    final titleCtrl = TextEditingController(text: doc?.data()?['title'] ?? '');
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
        lastDate: now.add(const Duration(days: 365 * 2)),
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
                        controller: titleCtrl,
                        label: 'Event Title',
                        hint: 'Enter event title',
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                      ),

                      SizedBox(height: MethodistTheme.spacingM),

                      AppTextField(
                        controller: descCtrl,
                        label: 'Description',
                        hint: 'Enter event description',
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Description is required' : null,
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
                            border: Border.all(color: MethodistTheme.mediumGray.withValues(alpha: 0.3)),
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
                                      selected == null
                                          ? 'Select date & time'
                                          : selected!.toLocal().toString().split('.').first,
                                      style: MethodistTheme.bodyMedium.copyWith(
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
            actions: [
              PrimaryButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              SizedBox(width: MethodistTheme.spacingS),
              PrimaryButton(
                label: doc == null ? 'Add Event' : 'Update Event',
                loading: loading,
                onPressed: () async {
                  if (!formKey.currentState!.validate() || selected == null) {
                    if (selected == null) {
                      MethodistTheme.showErrorSnackBar(context, 'Please select date and time');
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
                          context, doc == null ? 'Event added successfully' : 'Event updated successfully'
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event', style: MethodistTheme.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$title"? This cannot be undone.',
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
          .collection('myfs')
          .doc(widget.myfId)
          .collection('events')
          .doc(id)
          .delete();

      if (mounted) {
        MethodistTheme.showSuccessSnackBar(context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Failed to delete event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text('Manage Events - ${widget.myfTitle}'),
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
              description: 'No events have been created for this MYF group yet. Tap the + button to add the first event.',
            );
          }

          return ListView.builder(
            padding: MethodistTheme.paddingM,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final data = d.data();
              final raw = data['dateTime'];

              DateTime? dt;
              if (raw is String) dt = DateTime.tryParse(raw);
              if (raw is Timestamp) dt = raw.toDate();

              return InfoCard(
                title: data['title'] ?? 'Untitled Event',
                subtitle: dt != null
                    ? dt.toLocal().toString().split(' ').first
                    : 'No date set',
                description: data['description'] ?? 'No description',
                icon: Icons.event,
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit, color: MethodistTheme.warningOrange),
                    tooltip: 'Edit Event',
                    onPressed: () => _showEventDialog(doc: d),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: MethodistTheme.errorRed),
                    tooltip: 'Delete Event',
                    onPressed: () => _handleDeleteEvent(d.id, data['title'] ?? 'Untitled Event'),
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