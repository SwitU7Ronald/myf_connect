import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp, QuerySnapshot, DocumentSnapshot;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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
    return di.sl<AdminRepository>().getEventsStream('myfs', widget.myfId)
        as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  Future<void> _showEventDialog({
    DocumentSnapshot<Map<String, dynamic>>? doc,
  }) async {
    final titleCtrl = TextEditingController(
      text: doc?.data()?['title'] as String? ?? '',
    );
    final descCtrl = TextEditingController(
      text: doc?.data()?['description'] as String? ?? '',
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

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => PlatformAlertDialog(
            title: Text(
              doc == null ? 'Add MYF Event' : 'Edit MYF Event',
              style: context.typography.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
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
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),

                      SizedBox(height: context.spacingMd),

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

                      SizedBox(height: context.spacingMd),

                      InkWell(
                        onTap: () async {
                          await pickDateTime(dialogContext);
                          setDialogState(() {});
                        },
                        borderRadius: BorderRadius.circular(
                          context.radiusMd.topLeft.x,
                        ),
                        child: Container(
                          padding: context.responsivePadding(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              context.radiusMd.topLeft.x,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: context.colors.primary,
                                size: context.responsiveIconSize(20),
                              ),
                              SizedBox(width: context.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date & Time',
                                      style: context.typography.labelMedium!
                                          .copyWith(
                                            color: context.colors.textSecondary,
                                          ),
                                    ),
                                    SizedBox(height: context.spacingXs),
                                    Text(
                                      selected == null
                                          ? 'Select date & time'
                                          : selected!
                                                .toLocal()
                                                .toString()
                                                .split('.')
                                                .first,
                                      style: context.typography.bodyMedium!
                                          .copyWith(
                                            color: selected == null
                                                ? context.colors.textSecondary
                                                : context.colors.textPrimary,
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
                onPressed: () => dialogContext.pop(),
              ),
              SizedBox(width: context.spacingSm),
              PrimaryButton(
                label: doc == null ? 'Add Event' : 'Update Event',
                loading: loading,
                onPressed: () async {
                  if (!formKey.currentState!.validate() || selected == null) {
                    if (selected == null) {
                      AppSnackbars.showError(
                        context,
                        'Please select date and time',
                      );
                    }
                    return;
                  }

                  setDialogState(() => loading = true);

                  try {
                    final payload = {
                      'title': titleCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'dateTime': Timestamp.fromDate(selected!),
                    };

                    if (doc == null) {
                      await di.sl<AdminRepository>().createEvent(
                        'myfs',
                        widget.myfId,
                        payload,
                      );
                    } else {
                      await di.sl<AdminRepository>().updateEvent(
                        'myfs',
                        widget.myfId,
                        doc.id,
                        payload,
                      );
                    }

                    if (dialogContext.mounted) {
                      AppSnackbars.showSuccess(
                        context,
                        doc == null
                            ? 'Event added successfully'
                            : 'Event updated successfully',
                      );
                      dialogContext.pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      AppSnackbars.showError(context, 'Error: $e');
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
      builder: (context) => PlatformAlertDialog(
        title: Text('Delete Event', style: context.typography.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$title"? This cannot be undone.',
          style: context.typography.bodyMedium,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: context.spacingMd, vertical: context.spacingMd),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => context.pop(false),
          ),
          SizedBox(width: context.spacingSm),
          PrimaryButton.danger(
            label: 'Delete',
            onPressed: () => context.pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await di.sl<AdminRepository>().deleteEvent('myfs', widget.myfId, id);

      if (mounted) {
        AppSnackbars.showSuccess(context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Failed to delete event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.background,
      appBar: PlatformAppBar(
        title: Text(
          'Manage Events - ${widget.myfTitle}',
          style: context.typography.headlineSmall!.copyWith(
            color: context.colors.surface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        tooltip: 'Add Event',
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
        child: Icon(Icons.add, size: context.responsiveIconSize(28)),
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              Widget buildItem(BuildContext context, int index) {
                final d = docs[index];
                final data = d.data();
                final raw = data['dateTime'];

                DateTime? dt;
                if (raw is String) dt = DateTime.tryParse(raw);
                if (raw is Timestamp) dt = raw.toDate();

                return InfoCard(
                  title: data['title'] as String? ?? 'Untitled Event',
                  subtitle: dt != null
                      ? dt.toLocal().toString().split(' ').first
                      : 'No date set',
                  description:
                      data['description'] as String? ?? 'No description',
                  icon: Icons.event,
                  actions: [
                    Tooltip(
                      message: 'Edit Event',
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: context.colors.warning,
                          size: context.responsiveIconSize(20),
                        ),
                        onPressed: () => _showEventDialog(doc: d),
                      ),
                    ),
                    Tooltip(
                      message: 'Delete Event',
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: context.colors.error,
                          size: context.responsiveIconSize(20),
                        ),
                        onPressed: () => _handleDeleteEvent(
                          d.id,
                          data['title'] as String? ?? 'Untitled Event',
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (isWide) {
                return GridView.builder(
                  padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    crossAxisSpacing: context.spacingMd,
                    mainAxisSpacing: context.spacingMd,
                    mainAxisExtent: 180,
                  ),
                  itemCount: docs.length,
                  itemBuilder: buildItem,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < docs.length - 1 ? context.spacingMd : 0,
                    ),
                    child: buildItem(context, index),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
