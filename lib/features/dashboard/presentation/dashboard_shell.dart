import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../transactions/presentation/transaction_form_sheet.dart';
import 'widgets/dashboard_bottom_nav.dart';

/// Hosts the go_router [StatefulShellRoute] branches (Home/Activity/Budget/
/// Accounts/Settings) behind a persistent bottom nav bar, plus a quick-add
/// FAB that's reachable no matter which tab is active.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionFormSheet(context),
        tooltip: 'Add transaction',
        child: const Icon(Icons.add),
      ),
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
