import 'package:gtfs_db/gtfs_db.dart';

class TripsWithStopTimes {
  final StopTime stopTime;
  final Trip trip;
  final TransitRoute route;

  TripsWithStopTimes(this.stopTime, this.trip, this.route);
}

class StopWithStopTimes {
  final Stop stop;
  final StopTime stopTime;

  StopWithStopTimes(this.stop, this.stopTime);
}
