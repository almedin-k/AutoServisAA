import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/service_management_screen.dart';
import '../theme/app_theme.dart';
import '../utils/utils_widgets.dart';

// Sidebar
enum AppSection { dashboard, appointments, serviceManagement, reports, settings }

// Screen layout
class MasterScreen extends StatelessWidget {
  const MasterScreen({
    super.key,
    required this.title,
    required this.child,
    this.section = AppSection.dashboard,
    this.showBackButton = false,
  });

  final String title;
  final Widget child;

  // Selected sidebar item
  final AppSection section;

  // Back button for Add and Edit screens
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(current: section),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeading(context),
                        const SizedBox(height: 18),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Nazad'),
          ),
          const SizedBox(width: 16),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.section,
    required this.icon,
    required this.label,
    this.disabledReason,
  });

  final AppSection section;
  final IconData icon;
  final String label;

  // When set, the item is disabled and the reason why is shown as a tooltip.
  final String? disabledReason;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.current});

  final AppSection current;

  static const String _laterRelease = 'Ovaj dio još nije dostupan.';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isStaff = auth.isStaff;

    final items = [
      const _NavItem(section: AppSection.dashboard, icon: Icons.dashboard_outlined, label: 'Kontrolna tabla'),
      const _NavItem(
        section: AppSection.appointments,
        icon: Icons.calendar_month_outlined,
        label: 'Rezervacije',
        disabledReason: _laterRelease,
      ),
      _NavItem(
        section: AppSection.serviceManagement,
        icon: Icons.build_outlined,
        label: 'Upravljanje uslugama',
        disabledReason: isStaff ? null : 'Uslugama mogu upravljati samo menadžeri i administratori.',
      ),
      const _NavItem(
        section: AppSection.reports,
        icon: Icons.bar_chart_outlined,
        label: 'Izvještaji',
        disabledReason: _laterRelease,
      ),
      const _NavItem(
        section: AppSection.settings,
        icon: Icons.settings_outlined,
        label: 'Postavke',
        disabledReason: _laterRelease,
      ),
    ];

    return Container(
      width: 250,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Icon(Icons.directions_car_filled_outlined, color: AppColors.primary, size: 28),
                SizedBox(width: 10),
                Text(
                  'AutoServisAA',
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          for (final item in items) _SidebarTile(item: item, selected: item.section == current),
          const Spacer(),
          const Divider(color: AppColors.sidebarHover),
          _UserRow(auth: auth),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final disabled = item.disabledReason != null;
    final color = disabled ? AppColors.sidebarMuted : (selected ? Colors.white : AppColors.sidebarText);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.sidebarHover,
          onTap: disabled ? null : () => _open(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return disabled ? Tooltip(message: item.disabledReason!, child: tile) : tile;
  }

  void _open(BuildContext context) {
    final Widget target = switch (item.section) {
      AppSection.serviceManagement => const ServiceManagementScreen(),
      _ => const DashboardScreen(),
    };

    // The new section replaces the whole stack, so Back never leads to an old section.
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => target,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.sidebarHover,
            child: Text(
              _initials(user?.firstName, user?.lastName),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user == null ? '' : '${user.roleLabel}: ${user.firstName}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.sidebarText),
            ),
          ),
          IconButton(
            tooltip: 'Odjavi se',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, color: AppColors.sidebarText, size: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final provider = context.read<AuthProvider>();

    final confirmed = await confirmDialog(
      context,
      title: 'Odjava',
      message: 'Jeste li sigurni da se želite odjaviti?',
      confirmText: 'Odjavi se',
    );

    if (confirmed) {
      // The root widget listens to AuthProvider and moves to the login screen.
      await provider.logout();
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const IconButton(
            tooltip: 'Obavijesti još nisu dostupne.',
            onPressed: null,
            icon: Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              _initials(user?.firstName, user?.lastName),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (user != null) ...[
            const SizedBox(width: 10),
            Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

String _initials(String? firstName, String? lastName) {
  final first = (firstName ?? '').isEmpty ? '' : firstName![0];
  final last = (lastName ?? '').isEmpty ? '' : lastName![0];
  return '$first$last'.toUpperCase();
}
