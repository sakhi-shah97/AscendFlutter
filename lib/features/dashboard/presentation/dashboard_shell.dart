import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/dashboard_side_nav.dart';

/// Hosts the go_router [StatefulShellRoute] branches (Home/Activity/Budget/
/// Accounts/Settings). On a phone (or a narrow web window) that's a
/// persistent bottom nav bar; on a wide web window it's a side nav rail
/// instead, since a bar stretched across a desktop browser reads as an
/// afterthought. Either way a quick-add FAB is reachable no matter which
/// tab is active.
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final fab = FloatingActionButton(
      onPressed: () => showTransactionFormSheet(context),
      tooltip: 'Add transaction',
      child: const Icon(Icons.add),
    );

    final useSideNav = kIsWeb && MediaQuery.sizeOf(context).width >= AppBreakpoints.sideNav;

    if (useSideNav) {
      return Scaffold(
        body: Row(
          children: [
            DashboardSideNav(currentIndex: navigationShell.currentIndex, onTap: _onTap),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      body: navigationShell,
      floatingActionButton: fab,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
