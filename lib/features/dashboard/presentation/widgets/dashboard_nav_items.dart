import 'package:flutter/material.dart';

/// One destination shared between [DashboardBottomNav] (phone/narrow web)
/// and [DashboardSideNav] (wide web), so both stay in sync automatically.
class DashboardNavItem {
  const DashboardNavItem({required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const dashboardNavItems = [
  DashboardNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  DashboardNavItem(icon: Icons.bolt_outlined, activeIcon: Icons.bolt, label: 'Activity'),
  DashboardNavItem(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, label: 'Budget'),
  DashboardNavItem(
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet,
    label: 'Accounts',
  ),
  DashboardNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
];
