import 'package:flutter/material.dart';
import 'package:transit/screens/tabs/nearby_stops_tab.dart';
import 'package:transit/screens/tabs/realtime_vehicles_tab.dart';
import 'package:transit/screens/tabs/routes_tab.dart';
import 'package:transit/screens/tabs/stops_map_tab.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  int _currentIndex = 0;

  _HomeScreenTab get _currentTab => _tabs[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab.title),
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
    setState(() {
      _currentIndex = index;
    });
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
