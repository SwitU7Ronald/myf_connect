import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../camps/camps_list_page.dart';
import '../myfs/myfs_list_page.dart';
// Correct relative import

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      final adminClaim = idTokenResult.claims?['admin'] == true;
      if (mounted) {
        setState(() {
          _isAdmin = adminClaim;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Methodist Connect'),
          actions: [
            if (_isAdmin)
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
            labelColor: Colors.white, // Active tab text color
            unselectedLabelColor: Colors.white70, // Inactive tab text color
            indicatorColor: Colors.white, // Indicator underline color
            tabs: [
              Tab(text: 'Camps'),
              Tab(text: 'MYF'),
            ],
          ),
        ),
        body: const TabBarView(children: [CampsListPage(), MyfsListPage()]),
      ),
    );
  }
}
