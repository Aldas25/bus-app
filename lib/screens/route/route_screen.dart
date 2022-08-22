import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart'
    show VehiclePosition;
import 'package:transit/database/database_service.dart';
import 'package:transit/realtime/gtfs_realtime_service.dart';
import 'package:transit/widgets/app_future_loader.dart';
import 'package:transit/widgets/map/layers/shapes_polyline_layer.dart';
import 'package:transit/widgets/map/layers/stops_marker_layer.dart';
import 'package:transit/widgets/map/layers/vehicle_positions_markers_layer.dart';
import 'package:transit/widgets/map/transit_map.dart';

class RouteScreen extends StatelessWidget {
  final TransitRoute route;

  const RouteScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${route.route_short_name}: ${route.route_long_name}'),
      ),
      body: AppFutureBuilder<_RouteScreenFutureData>(
        future: _getFuture(context),
        builder: (context, data) {
          final gtfsRealtimeUrl = data.feedInfo.agency_gtfs_realtime_url;

          final stops = data.stops;
          final trips = data.trips;
          final tripIdsSet = trips.map((t) => t.trip_id).toSet();

          return StreamBuilder<List<VehiclePosition>>(
            stream: GTFSRealtimeService().streamGtfsRealtimeVehiclePositions(
              gtfsRealtimeUrl,
            ),
            builder: (context, snapshot) {
              final vehiclePositions = snapshot.data ?? [];
              final filteredVehiclePositions = vehiclePositions
                  .where((v) => tripIdsSet.contains(v.trip.tripId))
                  .toList();

              return TransitMap(
                stopsLayer: StopsMarkerLayer(stops: stops),
                shapesPolylineLayer: ShapesPolylineLayer(
                  lines: data.lines,
                  color: route.parsedRouteColor ?? Colors.indigo,
                ),
                vehiclePositionsLayer: VehiclePositionMarkersLayer(
                  vehiclePositions: filteredVehiclePositions,
                  trips: trips,
                  routes: [route],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<_RouteScreenFutureData> _getFuture(BuildContext context) async {
    final database = DatabaseService.get(context);

    return _RouteScreenFutureData(
      feedInfo: await database.getFeedInfo(),
      stops: await database.getStopsByRoute(route),
      trips: await database.getTripsByRoute(route),
      lines: await database.getShapesForRoute(route),
    );
  }
}

class _RouteScreenFutureData {
  final FeedInfoData feedInfo;
  final List<Stop> stops;
  final List<Trip> trips;
  final List<List<Shape>> lines;

  _RouteScreenFutureData({
    required this.feedInfo,
    required this.stops,
    required this.trips,
    required this.lines,
  });
}
