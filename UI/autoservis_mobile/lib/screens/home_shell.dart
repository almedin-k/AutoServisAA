import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'appointments_screen.dart';
import 'catalog_home_screen.dart';
import 'profile_screen.dart';
import 'service_list_screen.dart';

// The screen after sign in: four tabs with the bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _tabCount = 4;
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
    List.generate(_tabCount, (_) => GlobalKey<NavigatorState>());

  /// A tab is built the first time it is opened, not at the start.
  final List<bool> _visited = [true, false, false, false];
  int _index = 0;

  Widget _rootOf(int tab) {
    switch (tab) {
      case 0:
        return const CatalogHomeScreen();
      case 1:
        return const ServiceListScreen();
      case 2:
        return const AppointmentsScreen();
      default:
        return const ProfileScreen();
    }
  }

  void _select(int tab) {
    if (tab == _index) {
      // Pressing the active tab again goes back to its first screen.
      _navigatorKeys[tab].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _index = tab;
      _visited[tab] = true;
    });
  }

  void _onBack() {
    final navigator = _navigatorKeys[_index].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    } else if (_index != 0) {
      setState(() => _index = 0);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < _tabCount; i++)
              _visited[i]
                  ? Navigator(
                      key: _navigatorKeys[i],
                      onGenerateRoute: (settings) => MaterialPageRoute<void>(
                        settings: settings,
                        builder: (_) => _rootOf(i),
                      ),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Početna',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted),
              selectedIcon: Icon(Icons.format_list_bulleted),
              label: 'Usluge',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Rezervacije',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}