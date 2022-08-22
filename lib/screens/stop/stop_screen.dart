import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:transit/database/database_service.dart';
import 'package:transit/models/db.dart';
import 'package:transit/screens/trip/trip_screen.dart';
import 'package:transit/widgets/app_future_loader.dart';
import 'package:transit/navigator_routes.dart';

class StopScreen extends StatelessWidget {
  final Stop stop;

  const StopScreen({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stop.stop_name),
      ),
      body: AppFutureBuilder<List<TripsWithStopTimes>>(
        future: DatabaseService.get(context).getStopTimesForStop(
          stop,
          DateTime.now(),
        ),
        builder: (context, tripsWithTimes) {
          return ListView.separated(
            itemCount: tripsWithTimes.length,
            separatorBuilder: (context, i) => Divider(height: 1),
            itemBuilder: (context, index) {
              final tripWithTime = tripsWithTimes[index];

              return TripStopTimeListTile(
                stop: stop,
                route: tripWithTime.route,
                trip: tripWithTime.trip,
                stopTime: tripWithTime.stopTime,
              );
            },
          );
        },
      ),
    );
  }
}

class TripStopTimeListTile extends StatelessWidget {
  final Stop stop;
  final StopTime stopTime;
  final Trip trip;
  final TransitRoute route;

  const TripStopTimeListTile({
    super.key,
    required this.stop,
    required this.stopTime,
    required this.route,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final routeShortName = route.route_short_name ?? '';
    final routeLongName = route.route_long_name;
    final routeTextColor = route.parsedRouteTextColor;
    final routeColor = route.parsedRouteColor;
    final tripHeadsign = trip.trip_headsign ?? '';
    final arrivalTime = stopTime.arrival_time;

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

    /*final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tripHeadsign, style: TextStyle(fontWeight: FontWeight.bold),),
        Text(routeLongName),
      ]
    );*/

    final arrivalTimeText = Text(arrivalTime.substring(0, arrivalTime.length-3));

    return ListTile(
      leading: tripNumberContainer,
      //title: titleColumn,
      title: Text(tripHeadsign),
      subtitle: Text(routeLongName),
      trailing: arrivalTimeText,
      onTap: () {
        Navigator.pushNamed(
          context,
          NavigatorRoutes.routeTrip,
          arguments: TripScreenArguments(route:route, trip:trip, stop:stop),
        );
      },
    );
  }
}
