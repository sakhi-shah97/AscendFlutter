import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'dashboard_nav_items.dart';

/// The wide-web counterpart to [DashboardBottomNav] — a fixed, extended
/// [NavigationRail] down the left edge instead of a bar stretched across
/// the bottom of a desktop-sized browser window.
class DashboardSideNav extends StatelessWidget {
  const DashboardSideNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      extended: true,
      minExtendedWidth: 220,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.gold.withValues(alpha: 0.18),
      selectedIconTheme: const IconThemeData(color: AppColors.gold),
      selectedLabelTextStyle: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
      unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
      unselectedLabelTextStyle: const TextStyle(color: AppColors.textMuted),
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ascend',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.goldHigh),
          ),
        ),
      ),
      destinations: [
        for (final item in dashboardNavItems)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: Text(item.label),
          ),
      ],
    );
  }
}
