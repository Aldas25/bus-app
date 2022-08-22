import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;

class GTFSRealtimeService {
  Future<FeedMessage> _fetchGtfRealtime(String gtfsRealtimeUrl) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = '$gtfsRealtimeUrl?time=$timestamp';
    final response = await http.get(Uri.parse(url));
    final message = FeedMessage.fromBuffer(response.bodyBytes);

    return message;
  }

  Stream<FeedMessage> _streamGtfsRealtime(String gtfsRealtimeUrl) async* {
    yield await _fetchGtfRealtime(gtfsRealtimeUrl);

    yield* Stream.periodic(Duration(seconds: 10)).asyncMap<FeedMessage>(
      (e) => _fetchGtfRealtime(gtfsRealtimeUrl),
    );
  }

  Stream<List<VehiclePosition>> streamGtfsRealtimeVehiclePositions(
    String? gtfsRealtimeUrl,
  ) {
    if (gtfsRealtimeUrl != null) {
      return _streamGtfsRealtime(gtfsRealtimeUrl).map(
        (r) => r.entity
            .where((e) => e.hasVehicle())
            .map((e) => e.vehicle)
            .toList(),
      );
    } else {
      return Stream.value([]);
    }
  }
}
