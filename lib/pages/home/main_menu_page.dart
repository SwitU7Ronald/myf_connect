import 'package:flutter/material.dart';
import '../../app_router.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Methodist Connect'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Camps'),
              Tab(text: 'MYF'),
              Tab(text: 'Others'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Camps
            _CampsTab(),
            // MYF
            Center(child: Text('MYF section')),
            // Others
            Center(child: Text('Others section')),
          ],
        ),
      ),
    );
  }
}

class _CampsTab extends StatelessWidget {
  const _CampsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.camps),
        child: const Text('Open Camps'),
      ),
    );
  }
}
