import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:transit/models/db.dart';
export 'package:transit/models/db_extensions.dart';

class DatabaseService extends AppDatabase {
  DatabaseService(super.e);

  static DatabaseService get(BuildContext context) {
    return Provider.of<DatabaseService>(
      context,
      listen: false,
    );
  }

  Future<List<TransitRoute>> getAllRoutes() async {
    final routes = await select(transitRoutes).get();

    return routes.sortedByCompare(
      (r) => '${r.route_color} ${r.route_short_name}',
      compareNatural,
    );
  }

  Future<List<Trip>> getAllTrips() {
    return select(trips).get();
  }

  Future<List<Trip>> getTripsByRoute(TransitRoute route) {
    final query = select(trips)
      ..where((t) => t.route_id.equals(route.route_id));

    return query.get();
  }

  Future<FeedInfoData> getFeedInfo() {
    return select(feedInfo).getSingle();
  }

  Future<List<Stop>> getAllStops() {
    return select(stops).get();
  }

  Future<List<Stop>> getAllStopsOrderedByDistance({
    required LatLng currentPosition,
  }) async {
    final allStops = await getAllStops();
    final distance = Distance();

    return allStops.sortedBy<num>(
      (s) => distance.as(
        LengthUnit.Meter,
        LatLng(s.stop_lat, s.stop_lon),
        currentPosition,
      ),
    );
  }

  Future<List<TransitRoute>> selectRoutesByStop(Stop stop) {
    return select(transitRoutes)
        .join(
          [
            innerJoin(
              trips,
              trips.route_id.equalsExp(transitRoutes.route_id),
              useColumns: false,
            ),
            innerJoin(
              stopTimes,
              stopTimes.trip_id.equalsExp(trips.trip_id) &
                  stopTimes.stop_id.equals(stop.stop_id),
              useColumns: false,
            ),
          ],
        )
        .map((row) => row.readTable(transitRoutes))
        .get();
  }

  Future<List<Stop>> getStopsByRoute(TransitRoute route) {
    final query = select(stops).join([
      innerJoin(
        stopTimes,
        stopTimes.trip_id.equalsExp(trips.trip_id) &
            stopTimes.stop_id.equalsExp(stops.stop_id),
        useColumns: false,
      ),
      innerJoin(
        trips,
        trips.route_id.equals(route.route_id),
        useColumns: false,
      ),
    ])
      ..groupBy([stops.stop_id]);

    return query.map((row) => row.readTable(stops)).get();
  }

  Expression<bool> _calendarWeekdayExpression(DateTime dateTime) {
    switch (dateTime.weekday) {
      case DateTime.monday:
        return calendar.monday.equals(true);
      case DateTime.tuesday:
        return calendar.tuesday.equals(true);
      case DateTime.wednesday:
        return calendar.wednesday.equals(true);
      case DateTime.thursday:
        return calendar.thursday.equals(true);
      case DateTime.friday:
        return calendar.friday.equals(true);
      case DateTime.saturday:
        return calendar.saturday.equals(true);
      case DateTime.sunday:
        return calendar.sunday.equals(true);
      default:
        throw Exception('Unable to map weekday');
    }
  }

  Future<List<TripsWithStopTimes>> getStopTimesForStop(
    Stop stop,
    DateTime dateTime,
  ) {
    final localDateTime = dateTime.toLocal();

    final timeFormat = DateFormat('HH:mm:ss');
    final timeFormatted = timeFormat.format(localDateTime.toLocal());
    final dateFormat = DateFormat('yyyyMMdd');
    final dateFormatted = dateFormat.format(localDateTime.toLocal());

    final query = select(stopTimes)
      ..where((s) => s.stop_id.equals(stop.stop_id))
      ..where((s) => s.arrival_time.isBiggerOrEqualValue(timeFormatted))
      ..orderBy([
        (t) => OrderingTerm(expression: t.arrival_time),
        (t) => OrderingTerm(expression: t.departure_time),
      ]);

    final joinedQuery = query.join([
      innerJoin(
        trips,
        trips.trip_id.equalsExp(stopTimes.trip_id),
      ),
      innerJoin(
        transitRoutes,
        transitRoutes.route_id.equalsExp(trips.route_id),
      ),
      innerJoin(
        calendar,
        calendar.service_id.equalsExp(trips.service_id) &
            calendar.start_date.isSmallerOrEqualValue(dateFormatted) &
            calendar.end_date.isBiggerOrEqualValue(dateFormatted) &
            _calendarWeekdayExpression(localDateTime),
      ),
    ]).map((row) {
      return TripsWithStopTimes(
        row.readTable(stopTimes),
        row.readTable(trips),
        row.readTable(transitRoutes),
      );
    });

    return joinedQuery.get();
  }

  Future<List<StopWithStopTimes>> getStopWithStopTimesForTrip({
    required Trip trip,
  }) {
    final query = select(stopTimes)
      ..where((s) => s.trip_id.equals(trip.trip_id))
      ..orderBy([
        (t) => OrderingTerm.asc(t.stop_sequence),
      ]);

    final joinedQuery = query.join([
      innerJoin(
        stops,
        stops.stop_id.equalsExp(stopTimes.stop_id),
      ),
    ]).map((row) {
      return StopWithStopTimes(
        row.readTable(stops),
        row.readTable(stopTimes),
      );
    });

    return joinedQuery.get();
  }

  Future<List<Shape>> getShapesForTrip(Trip trip) {
    final query = select(shapes)
      ..where((s) => s.shape_id.equals(trip.shape_id))
      ..orderBy([(s) => OrderingTerm.asc(s.shape_pt_sequence)]);

    return query.get();
  }

  Future<List<List<Shape>>> getShapesForRoute(TransitRoute route) async {
    final query = select(shapes).join([
      innerJoin(
        trips,
        (trips.shape_id.equalsExp(shapes.shape_id)) &
            (trips.route_id.equals(route.route_id)),
        useColumns: false,
      )
    ])
      ..groupBy([shapes.shape_id, shapes.shape_pt_sequence]);

    final rows = await query.map((r) => r.readTable(shapes)).get();

    return groupBy<Shape, String>(rows, (r) => r.shape_id).values.toList();
  }
}
