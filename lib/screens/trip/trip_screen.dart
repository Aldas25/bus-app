import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:transit/database/database_service.dart';
import 'package:transit/models/db.dart';
import 'package:transit/screens/trip/trip_screen_body.dart';
import 'package:transit/screens/trip/trip_screen_map.dart';
import 'package:transit/widgets/app_future_loader.dart';

class TripScreenArguments {
  final TransitRoute route;
  final Trip trip;
  final Stop? stop;

  TripScreenArguments({
    required this.route,
    required this.trip,
    required this.stop,
  });
}

class TripScreen extends StatelessWidget {
  final TripScreenArguments arguments;

  Stop? get selectedStop => arguments.stop;

  TransitRoute get selectedRoute => arguments.route;

  Trip get selectedTrip => arguments.trip;

  TripScreen({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder<_TripData>(
      future: _getTripData(context),
      builder: (context, tripData) {
        final stopsWithStopTimes = tripData.stopsWithStopTimes;
        final stops = stopsWithStopTimes.map((st) => st.stop).toList();
        final shapes = tripData.shapes;

        return BackdropScaffold(
          appBar: BackdropAppBar(
            title: Text(
              '${selectedRoute.route_short_name}: ${selectedTrip.trip_short_name ?? selectedRoute.route_long_name}',
            ),
            leading: BackButton(),
            actions: [BackdropToggleButton()],
          ),
          backLayer: TripScreenMap(
            selectedRoute: selectedRoute,
            stops: stops,
            shapes: shapes,
          ),
          frontLayer: TripScreenListBody(
            selectedStop: selectedStop,
            stopsWithStopTimes: stopsWithStopTimes,
          ),
        );
      },
    );
  }

  Future<_TripData> _getTripData(BuildContext context) async {
    final database = DatabaseService.get(context);

    final stopWithStopTimes = await database.getStopWithStopTimesForTrip(
      trip: selectedTrip,
    );

    final shapes = await database.getShapesForTrip(selectedTrip);

    return _TripData(
      stopsWithStopTimes: stopWithStopTimes,
      shapes: shapes,
    );
  }
}

class _TripData {
  final List<StopWithStopTimes> stopsWithStopTimes;
  final List<Shape> shapes;

  _TripData({
    required this.stopsWithStopTimes,
    required this.shapes,
  });
}
