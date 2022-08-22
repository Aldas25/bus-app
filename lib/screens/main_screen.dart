import 'package:flutter/material.dart';
import 'package:transit/screens/tabs/nearby_stops_tab.dart';
import 'package:transit/screens/tabs/realtime_vehicles_tab.dart';
import 'package:transit/screens/tabs/routes_tab.dart';
import 'package:transit/screens/tabs/stops_map_tab.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final List<_HomeScreenTab> _tabs = [
    _HomeScreenTab(
      title: 'Artimiausios stotelės',
      label: 'Artimiausios',
      builder: () => NearbyStopsTab(),
      icon: Icons.near_me,
      activeIcon: Icons.near_me_outlined,
    ),
    _HomeScreenTab(
      title: 'Stotelių žemėlapis',
      label: 'Stotelės',
      builder: () => StopsMapTab(),
      icon: Icons.pin_drop,
      activeIcon: Icons.pin_drop_outlined,
    ),
    _HomeScreenTab(
      title: 'Realus laikas',
      label: 'Realus laikas',
      builder: () => RealtimeVehiclesTab(),
      icon: Icons.directions_bus,
      activeIcon: Icons.directions_bus_outlined,
    ),
    _HomeScreenTab(
      title: 'Maršrutai',
      label: 'Maršrutai',
      builder: () => RoutesTab(),
      icon: Icons.route,
      activeIcon: Icons.route_outlined,
    ),
  ];

  final _currentIndex = 0;

  _HomeScreenTab get _currentTab => _tabs[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: Exercise 1
        title: Text('TODO: Exercise 1'),
        centerTitle: true,
      ),
      body: _currentTab.builder(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              label: tab.label,
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
            ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    // TODO: Exercise 3
    print('Tapped index: $index, Current index: $_currentIndex');
  }
}

class _HomeScreenTab {
  final String title;
  final String label;
  final Widget Function() builder;
  final IconData icon;
  final IconData activeIcon;

  const _HomeScreenTab({
    required this.title,
    required this.label,
    required this.builder,
    required this.icon,
    required this.activeIcon,
  });
}
