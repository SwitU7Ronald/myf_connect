import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';
import '../../../app/theme.dart';
import 'camps_create_page.dart';
import './camps_events_management_page.dart';

class CampsManagementPage extends StatelessWidget {
  const CampsManagementPage({super.key});

  Future<void> _navigateToCreateCamp(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CampsCreatePage()),
    );
  }

  Future<void> _deleteCampEventsCascade(String campId) async {
    final eventsRef = FirebaseFirestore.instance
        .collection('camps')
        .doc(campId)
        .collection('events');

    const pageSize = 250;
    while (true) {
      final page = await eventsRef
          .orderBy(FieldPath.documentId)
          .limit(pageSize)
          .get(const GetOptions(source: Source.server));
      if (page.docs.isEmpty) break;

      final batch = FirebaseFirestore.instance.batch();
      for (final d in page.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteCamp(BuildContext context, String id, String title) async {
    // Step 1: Show confirmation dialog - ✅ RESPONSIVE
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Camp',
          // ✅ RESPONSIVE: Use responsive text style
          style: context.responsiveHeadlineSmall,
        ),
        content: Text(
          'Are you sure you want to delete "$title" and all its events? This cannot be undone.',
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
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          SizedBox(width: context.spacing(8)),
          PrimaryButton.danger(
            label: 'Delete',
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Step 2: Store the navigator state BEFORE showing loading
    final navigator = Navigator.of(context);

    // Step 3: Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => PopScope(
        canPop: false,
        child: const LoadingWidget(message: 'Deleting camp and events...'),
      ),
    );

    try {
      // Step 4: Delete events
      await _deleteCampEventsCascade(id);

      // Step 5: Delete camp
      await FirebaseFirestore.instance.collection('camps').doc(id).delete();

      // Step 6: Close loading dialog using stored navigator
      navigator.pop();

      // Step 7: Show success message
      if (context.mounted) {
        MethodistTheme.showSuccessSnackBar(
          context,
          'Camp and all events deleted successfully',
        );
      }
    } catch (e) {
      debugPrint('❌ Camp Delete Error: $e');

      // Close loading dialog using stored navigator
      navigator.pop();

      // Show error message
      if (context.mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Failed to delete camp: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _showEditCampDialog(
      BuildContext context,
      String campId,
      Map<String, dynamic> data,
      ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final placeCtrl = TextEditingController(text: data['place'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');

    DateTime? selectedDate = () {
      final raw = data['date'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }();

    bool loading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Edit Camp',
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
                    // Camp Title Field
                    AppTextField(
                      controller: titleCtrl,
                      label: 'Camp Title',
                      hint: 'Enter camp title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    // ✅ RESPONSIVE: Use context.spacing
                    SizedBox(height: context.spacing(16)),

                    // Camp Place Field
                    AppTextField(
                      controller: placeCtrl,
                      label: 'Place',
                      hint: 'Enter camp location',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Place is required'
                          : null,
                    ),
                    SizedBox(height: context.spacing(16)),

                    // Camp Date Field
                    DatePickerField.dateOnly(
                      selectedDateTime: selectedDate,
                      label: 'Camp Date',
                      hint: 'Select camp date',
                      firstDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                      onDateTimeSelected: (date) =>
                          setDialogState(() => selectedDate = date),
                    ),
                    SizedBox(height: context.spacing(16)),

                    // Camp Description Field
                    AppTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hint: 'Enter camp description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
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
              label: 'Update Camp',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedDate == null) {
                  if (selectedDate == null) {
                    MethodistTheme.showErrorSnackBar(
                        context, 'Please select a date');
                  }
                  return;
                }

                setDialogState(() => loading = true);

                try {
                  // Calculate day of week
                  final dayOfWeek = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ];
                  final day = dayOfWeek[selectedDate!.weekday - 1];

                  await FirebaseFirestore.instance
                      .collection('camps')
                      .doc(campId)
                      .update({
                    'title': titleCtrl.text.trim(),
                    'place': placeCtrl.text.trim(),
                    'date': Timestamp.fromDate(selectedDate!),
                    'day': day, // ✅ Add day field
                    'description': descCtrl.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    MethodistTheme.showSuccessSnackBar(
                        context, 'Camp updated successfully');
                  }
                } catch (e) {
                  debugPrint('Camp Update Error: $e');
                  MethodistTheme.showErrorSnackBar(
                      context, 'Error updating camp: $e');
                } finally {
                  setDialogState(() => loading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Camps Management',
          // ✅ RESPONSIVE: Use responsive text style
          style: context.responsiveHeadlineSmall.copyWith(
            color: MethodistTheme.white,
          ),
        ),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCamp(context),
        tooltip: 'Add Camp',
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        // ✅ RESPONSIVE: Use responsive icon size
        child: Icon(
          Icons.add,
          size: context.responsiveIconSize(28),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('date')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading camps...');
          }

          if (snap.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading Camps',
              description: 'Error: ${snap.error}',
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CampsManagementPage()),
                );
              },
            );
          }

          final camps = snap.data!.docs;

          if (camps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.campaign,
              title: 'No Camps Found',
              description:
              'No camps have been created yet. Tap the + button to create your first camp.',
            );
          }

          return ListView.builder(
            // ✅ RESPONSIVE: Use context.responsivePadding
            padding: context.responsivePadding(all: 16),
            itemCount: camps.length,
            itemBuilder: (context, index) {
              final camp = camps[index];
              final campId = camp.id;
              final data = camp.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Unnamed Camp';
              final place = data['place'] ?? '';

              // Parse date
              String dateStr = '';
              final dateVal = data['date'];
              if (dateVal is Timestamp) {
                dateStr =
                    dateVal.toDate().toLocal().toString().split(' ').first;
              } else if (dateVal is String) {
                final parsedDate = DateTime.tryParse(dateVal);
                dateStr = parsedDate?.toLocal().toString().split(' ').first ?? '';
              }

              return Column(
                children: [
                  InfoCard(
                    title: title,
                    subtitle: place.isNotEmpty ? place : null,
                    description:
                    dateStr.isNotEmpty ? 'Date: $dateStr' : null,
                    icon: Icons.campaign,
                    actions: [
                      // Edit Button - ✅ RESPONSIVE
                      Tooltip(
                        message: 'Edit Camp',
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: MethodistTheme.warningOrange,
                            size: context.responsiveIconSize(20),
                          ),
                          onPressed: () =>
                              _showEditCampDialog(context, campId, data),
                        ),
                      ),
                      // Events Button - ✅ RESPONSIVE
                      Tooltip(
                        message: 'Manage Events',
                        child: IconButton(
                          icon: Icon(
                            Icons.event,
                            color: MethodistTheme.infoBlue,
                            size: context.responsiveIconSize(20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CampsEventsManagementPage(
                                      campId: campId,
                                      campTitle: title,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Delete Button - ✅ RESPONSIVE
                      Tooltip(
                        message: 'Delete Camp',
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: MethodistTheme.errorRed,
                            size: context.responsiveIconSize(20),
                          ),
                          onPressed: () =>
                              _deleteCamp(context, campId, title),
                        ),
                      ),
                    ],
                  ),
                  // ✅ RESPONSIVE: Use context.spacing between items
                  if (index < camps.length - 1)
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
