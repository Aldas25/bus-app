import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart' as rt;
import 'package:latlong2/latlong.dart';
import 'package:transit/models/db_extensions.dart';
import 'package:transit/navigator_routes.dart';
import 'package:transit/screens/trip/trip_screen.dart';
import 'package:vector_math/vector_math.dart';

class VehiclePositionMarkersLayer {
  final List<rt.VehiclePosition> vehiclePositions;
  final List<Trip> trips;
  final List<TransitRoute> routes;

  late Map<String, Trip> tripsLookup;
  late Map<String, TransitRoute> routesLookup;

  VehiclePositionMarkersLayer({
    required this.vehiclePositions,
    required this.trips,
    required this.routes,
  }) {
    tripsLookup = new Map();
    routesLookup = new Map();

    for (final trip in trips) {
      tripsLookup[trip.trip_id] = trip;
    }

    for (final route in routes) {
      routesLookup[route.route_id] = route;
    }
  }

  MarkerLayerOptions buildLayer() {
    return MarkerLayerOptions(
      markers: [
        for (final vehiclePosition in vehiclePositions)
          Marker(
            point: LatLng(
              vehiclePosition.position.latitude,
              vehiclePosition.position.longitude,
            ),
            anchorPos: AnchorPos.align(AnchorAlign.center),
            //width: 20,
            //height: 20,
            builder: (context) {
              return getVehicleContainer(vehiclePosition, context);
            },
          ),
      ],
    );
  }

  Widget getVehicleContainer(
      rt.VehiclePosition vehiclePosition, BuildContext context) {
    final tripId = vehiclePosition.trip.tripId;

    final emptyContainer = getEmptyContainer(vehiclePosition);

    if (!vehiclePosition.trip.hasTripId()) {
      return emptyContainer;
    }

    final trip = tripsLookup[tripId];

    if (trip == null) {
      return emptyContainer;
    }

    final routeId = trip.route_id;
    final route = routesLookup[routeId];

    if (route == null) {
      return emptyContainer;
    }

    final routeShortName = route.route_short_name ?? '';
    final routeTextColor = route.parsedRouteTextColor;
    final routeColor = route.parsedRouteColor;

    final angle = radians(vehiclePosition.position.bearing) + pi * 3 / 4;

    final rotatedColorContainer = Transform.rotate(
      angle: angle,
      alignment: Alignment.center,
      child: Container(
        //alignment: Alignment.center,
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: routeColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(100.0),
              bottomRight: Radius.circular(100.0),
              topLeft: Radius.circular(100.0),
              bottomLeft: Radius.circular(0.0)),
        ),
      ),
    );

    final componentStack = Stack(
      children: <Widget>[
        rotatedColorContainer,
        Container(
          child: Text(
            routeShortName,
            style: TextStyle(color: routeTextColor),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 0, 6, 6),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          NavigatorRoutes.routeTrip,
          arguments: TripScreenArguments(route: route, trip: trip, stop: null),
        );
      },
      child: componentStack,
    );
  }

  Widget getEmptyContainer(rt.VehiclePosition vehiclePosition) {
    final angle = radians(vehiclePosition.position.bearing) + pi * 3 / 4;

    final rotatedColorContainer = Transform.rotate(
      angle: angle,
      alignment: Alignment.center,
      child: Container(
        //alignment: Alignment.center,
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: const Color(0xFF42A5F5),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(100.0),
              bottomRight: Radius.circular(100.0),
              topLeft: Radius.circular(100.0),
              bottomLeft: Radius.circular(0.0)),
        ),
        //padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
      ),
    );

    final componentStack = Stack(
      children: <Widget>[
        rotatedColorContainer,
        Container(
          child: Icon(
            Icons.directions_bus,
            size: 15,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 0, 6, 5),
        ),
      ],
    );

    return componentStack;
  }
}
