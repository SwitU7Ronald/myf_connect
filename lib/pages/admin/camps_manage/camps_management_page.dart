import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';
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
    // Step 1: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Camp', style: MethodistTheme.headlineSmall),
        content: Text(
          'Are you sure you want to delete "$title" and all its events? This cannot be undone.',
          style: MethodistTheme.bodyMedium,
        ),
        actions: [
          PrimaryButton.secondary(
            label: 'Cancel',
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          SizedBox(width: MethodistTheme.spacingS),
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
          title: Text('Edit Camp', style: MethodistTheme.headlineSmall),
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
                      label: 'Camp Title',
                      hint: 'Enter camp title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    AppTextField(
                      controller: placeCtrl,
                      label: 'Place',
                      hint: 'Enter camp location',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Place is required' : null,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    DatePickerField.dateOnly(
                      selectedDateTime: selectedDate,
                      label: 'Camp Date',
                      hint: 'Select camp date',
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      onDateTimeSelected: (date) => setDialogState(() => selectedDate = date),
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    AppTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hint: 'Enter camp description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
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
              label: 'Update Camp',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedDate == null) {
                  if (selectedDate == null) {
                    MethodistTheme.showErrorSnackBar(context, 'Please select a date');
                  }
                  return;
                }

                setDialogState(() => loading = true);

                try {
                  // Calculate day of week
                  final dayOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
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
                    MethodistTheme.showSuccessSnackBar(context, 'Camp updated successfully');
                  }
                } catch (e) {
                  debugPrint('Camp Update Error: $e');
                  MethodistTheme.showErrorSnackBar(context, 'Error updating camp: $e');
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
        title: const Text('Camps Management'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCamp(context),
        tooltip: 'Add Camp',
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        child: const Icon(Icons.add),
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
                  MaterialPageRoute(builder: (_) => const CampsManagementPage()),
                );
              },
            );
          }

          final camps = snap.data!.docs;

          if (camps.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.campaign,
              title: 'No Camps Found',
              description: 'No camps have been created yet. Tap the + button to create your first camp.',
            );
          }

          return ListView.builder(
            padding: MethodistTheme.paddingM,
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
                dateStr = dateVal.toDate().toLocal().toString().split(' ').first;
              } else if (dateVal is String) {
                final parsedDate = DateTime.tryParse(dateVal);
                dateStr = parsedDate?.toLocal().toString().split(' ').first ?? '';
              }

              return InfoCard(
                title: title,
                subtitle: place.isNotEmpty ? place : null,
                description: dateStr.isNotEmpty ? 'Date: $dateStr' : null,
                icon: Icons.campaign,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: MethodistTheme.warningOrange),
                    tooltip: 'Edit Camp',
                    onPressed: () => _showEditCampDialog(context, campId, data),
                  ),
                  IconButton(
                    icon: const Icon(Icons.event, color: MethodistTheme.infoBlue),
                    tooltip: 'Manage Events',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampsEventsManagementPage(
                            campId: campId,
                            campTitle: title,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: MethodistTheme.errorRed),
                    tooltip: 'Delete Camp',
                    onPressed: () => _deleteCamp(context, campId, title),
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
