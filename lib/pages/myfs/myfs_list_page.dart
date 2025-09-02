import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widgets.dart';
import 'myfs_detail_page.dart';

class MyfsListPage extends StatelessWidget {
  const MyfsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MYF Groups')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('myfs')
            .orderBy('title')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading MYF groups...');
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              title: 'Error Loading MYF Groups',
              description: 'Error: ${snapshot.error}',
              onRetry: () {
                // Trigger rebuild by navigating
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyfsListPage()),
                );
              },
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.group,
              title: 'No MYF Groups Available',
              description: 'Check back later for MYF groups and events.',
            );
          }

          final myfDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: MethodistTheme.paddingM,
            itemCount: myfDocs.length,
            itemBuilder: (context, index) {
              final myf = myfDocs[index];
              final data = myf.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled MYF';
              final description = data['description'] ?? '';

              return InfoCard(
                title: title,
                description: description.isNotEmpty ? description : 'No description available',
                icon: Icons.group,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyfsDetailPage(
                        myfId: myf.id,
                        myfTitle: title,
                      ),
                    ),
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