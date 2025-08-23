import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_user.dart';
import '../../app_router.dart';
import '../camps/camps_list_page.dart';  // Import the camps list page here

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!.data()!;
        final appUser = AppUser.fromMap(uid!, userData);
        final isAdmin = appUser.permissions.contains('admin');

        return DefaultTabController(
          length: 2, // Only Camps and MYF tabs
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Methodist Connect'),
              actions: [
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Admin Dashboard',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.adminDashboard);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Camps'),
                  Tab(text: 'MYF'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                CampsListPage(),  // Direct show camps list in this tab
                Center(child: Text('MYF section')), // Placeholder for MYF
              ],
            ),
          ),
        );
      },
    );
  }
}
