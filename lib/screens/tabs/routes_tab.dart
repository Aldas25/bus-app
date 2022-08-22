import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:transit/constants.dart';
import 'package:transit/database/database_service.dart';
import 'package:transit/navigator_routes.dart';
import 'package:transit/widgets/app_future_loader.dart';

class RoutesTab extends StatelessWidget {
  const RoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService.get(context);

    return AppFutureBuilder<List<TransitRoute>>(
      future: database.getAllRoutes(),
      builder: (BuildContext context, routes) {
        return ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            return RouteListTile(
              route: routes[index],
            );
          },
        );
      },
    );
  }
}

class RouteListTile extends StatelessWidget {
  final TransitRoute route;

  const RouteListTile({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final routeShortName = route.route_short_name ?? '';
    final routeTextColor = route.parsedRouteTextColor;
    final routeColor = route.parsedRouteColor;
    final routeLongName = route.route_long_name;

    final Container tripNumberContainer = Container(
      child: Text(
        routeShortName,
        style: TextStyle(color: routeTextColor),
      ),

      alignment: Alignment.center,
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: routeColor,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
            bottomRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
            bottomLeft: Radius.circular(10.0)
        ),
      ),
    );

    return ListTile(
      leading: tripNumberContainer,
      title: Text(routeLongName),

      onTap: () {
        Navigator.pushNamed(
          context,
          NavigatorRoutes.routeRoute,
          arguments: route,
        );
      },
    );
  }
}
