import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';
import 'myfs_events_management_page.dart';
import 'myfs_create_page.dart';

class MyfsManagementPage extends StatelessWidget {
  const MyfsManagementPage({super.key});

  Future<void> _navigateToCreateMyf(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyfsCreatePage()),
    );
  }

  Future<void> _deleteMyf(BuildContext context, String id, String title) async {
    // Step 1: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete MYF', style: MethodistTheme.headlineSmall),
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

    // Step 2: Store navigator BEFORE showing loading dialog
    final navigator = Navigator.of(context);

    // Step 3: Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => PopScope(
        canPop: false,
        child: const LoadingWidget(message: 'Deleting MYF and events...'),
      ),
    );

    try {
      // Step 4: Delete all events first
      final eventsRef = FirebaseFirestore.instance
          .collection('myfs')
          .doc(id)
          .collection('events');

      const pageSize = 250;
      while (true) {
        final page = await eventsRef
            .orderBy(FieldPath.documentId)
            .limit(pageSize)
            .get(const GetOptions(source: Source.server));
        if (page.docs.isEmpty) break;

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in page.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Step 5: Delete the MYF document
      await FirebaseFirestore.instance.collection('myfs').doc(id).delete();

      // Step 6: Close loading dialog using stored navigator
      navigator.pop();

      // Step 7: Show success message
      if (context.mounted) {
        MethodistTheme.showSuccessSnackBar(
          context,
          'MYF and all events deleted successfully',
        );
      }
    } catch (e) {
      debugPrint('❌ MYF Delete Error: $e');

      // Close loading dialog using stored navigator
      navigator.pop();

      // Show error message
      if (context.mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Failed to delete MYF: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _showEditMyfDialog(
      BuildContext context,
      String myfId,
      Map<String, dynamic> data,
      ) async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: data['title'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');
    bool loading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit MYF', style: MethodistTheme.headlineSmall),
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
                      label: 'MYF Title',
                      hint: 'Enter MYF group title',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    AppTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hint: 'Enter MYF group description',
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
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
              label: 'Update MYF',
              loading: loading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                setDialogState(() => loading = true);

                try {
                  await FirebaseFirestore.instance
                      .collection('myfs')
                      .doc(myfId)
                      .update({
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    MethodistTheme.showSuccessSnackBar(context, 'MYF updated successfully');
                  }
                } catch (e) {
                  debugPrint('❌ MYF Update Error: $e');
                  MethodistTheme.showErrorSnackBar(context, 'Error updating MYF: $e');
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
        title: const Text('MYF Management'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateMyf(context),
        tooltip: 'Add MYF',
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('myfs').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading MYF groups...');
          }

          if (snap.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading MYF Groups',
              description: 'Error: ${snap.error}',
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyfsManagementPage()),
                );
              },
            );
          }

          final myfDocs = snap.data!.docs;

          if (myfDocs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.group,
              title: 'No MYF Groups Found',
              description: 'No MYF groups have been created yet. Tap the + button to create your first MYF group.',
            );
          }

          return ListView.builder(
            padding: MethodistTheme.paddingM,
            itemCount: myfDocs.length,
            itemBuilder: (context, index) {
              final myf = myfDocs[index];
              final data = myf.data() as Map<String, dynamic>;
              final myfId = myf.id;
              final title = data['title'] ?? 'Untitled MYF';
              final description = data['description'] ?? '';

              return InfoCard(
                title: title,
                description: description.isNotEmpty ? description : 'No description available',
                icon: Icons.group,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: MethodistTheme.warningOrange),
                    tooltip: 'Edit MYF',
                    onPressed: () => _showEditMyfDialog(context, myfId, data),
                  ),
                  IconButton(
                    icon: const Icon(Icons.event, color: MethodistTheme.infoBlue),
                    tooltip: 'Manage Events',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyfsEventsManagementPage(
                            myfId: myfId,
                            myfTitle: title,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: MethodistTheme.errorRed),
                    tooltip: 'Delete MYF',
                    onPressed: () => _deleteMyf(context, myfId, title),
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
