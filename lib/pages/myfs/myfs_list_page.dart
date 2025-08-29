import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myfs_detail_page.dart';

class MyfsListPage extends StatelessWidget {
  const MyfsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myfStream = FirebaseFirestore.instance
        .collection('myfs')
        .orderBy('title')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: myfStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No MYF groups found'));
        }

        final myfDocs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: myfDocs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final myf = myfDocs[index];

            final data = myf.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled MYF';
            final description = data['description'] ?? '';

            return ListTile(
              title: Text(title),
              subtitle: Text(description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyfsDetailPage(myfId: myf.id, myfTitle: data['title'] ?? ''),
                    ),
                  );
                }

            );
          },
        );
      },
    );
  }
}
