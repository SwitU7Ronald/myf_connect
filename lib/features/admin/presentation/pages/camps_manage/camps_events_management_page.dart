import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:myf_connect/core/models/event.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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
  Stream<List<AppEvent>> _getEvents() {
    return di
        .sl<AdminRepository>()
        .getEventsStream('camps', widget.campId)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppEvent.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Future<void> _showEventDialog({AppEvent? event}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    final venueController = TextEditingController(text: event?.venue ?? '');

    DateTime? selectedDateTime = event?.dateTime;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => PlatformAlertDialog(
          title: Text(
            event == null ? 'Add Event' : 'Edit Event',
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
                      controller: titleController,
                      label: 'Event Title',
                      hint: 'Enter event title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    SizedBox(height: context.spacingMd),

                    AppTextField(
                      controller: venueController,
                      label: 'Venue',
                      hint: 'Enter event venue',
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: context.spacingMd),

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
                    SizedBox(height: context.spacingMd),

                    DatePickerField.dateTime(
                      selectedDateTime: selectedDateTime,
                      label: 'Event Date & Time',
                      hint: 'Select date and time',
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
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
              onPressed: () => dialogContext.pop(),
            ),
            SizedBox(width: context.spacingSm),
            PrimaryButton(
              label: event == null ? 'Add Event' : 'Update Event',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() ||
                    selectedDateTime == null) {
                  if (selectedDateTime == null) {
                    AppSnackbars.showError(
                      context,
                      'Please select date and time',
                    );
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
                    await di.sl<AdminRepository>().createEvent(
                      'camps',
                      widget.campId,
                      eventData,
                    );
                  } else {
                    await di.sl<AdminRepository>().updateEvent(
                      'camps',
                      widget.campId,
                      event.id,
                      eventData,
                    );
                  }

                  if (dialogContext.mounted) {
                    AppSnackbars.showSuccess(
                      context,
                      event == null
                          ? 'Event added successfully'
                          : 'Event updated successfully',
                    );
                    navigator.pop();
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
      ),
    );
  }

  Future<void> _deleteEvent(String eventId, String eventTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text('Delete Event', style: context.typography.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$eventTitle"? This cannot be undone.',
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
      await di.sl<AdminRepository>().deleteEvent(
        'camps',
        widget.campId,
        eventId,
      );

      if (mounted) {
        AppSnackbars.showSuccess(context, 'Event deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Error deleting event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: context.colors.background,
      appBar: PlatformAppBar(
        title: Text(
          'Manage Events - ${widget.campTitle}',
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
      body: StreamBuilder<List<AppEvent>>(
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              Widget buildItem(BuildContext context, int index) {
                final event = events[index];
                final dateStr = event.dateTime
                    .toLocal()
                    .toString()
                    .split('.')
                    .first;

                return InfoCard(
                  title: event.title,
                  subtitle: dateStr,
                  description: event.description,
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
                        onPressed: () => _showEventDialog(event: event),
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
                        onPressed: () => _deleteEvent(event.id, event.title),
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
                  itemCount: events.length,
                  itemBuilder: buildItem,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(top: context.appBarOverlap + context.spacingMd, left: context.spacingMd, right: context.spacingMd, bottom: context.spacingMd),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < events.length - 1
                          ? context.spacingMd
                          : 0,
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
