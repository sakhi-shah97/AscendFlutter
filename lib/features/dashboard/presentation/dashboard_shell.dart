import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/dashboard_bottom_nav.dart';

/// Hosts the go_router [StatefulShellRoute] branches (Home/Activity/Budget/
/// Accounts/Settings) behind a persistent bottom nav bar.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
