import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:transit/models/db_extensions.dart';
import 'package:transit/navigator_routes.dart';

class StopsMarkerLayer {
  final List<Stop> stops;

  StopsMarkerLayer({
    required this.stops,
  });

  MarkerLayerOptions buildLayer() {
    return MarkerLayerOptions(
      markers: [
        for (final stop in stops) _buildStopMarker(stop),
      ],
    );
  }

  Marker _buildStopMarker(Stop stop) {
    return Marker(
      key: Key('marker-stop-${stop.stop_id}'),
      point: stop.latLng,
      anchorPos: AnchorPos.align(AnchorAlign.center),
      width: 16,
      height: 16,
      builder: (context) {
        return GestureDetector(
          child: DecoratedBox(
            key: Key('marker-stop-body'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Colors.indigo,
            ),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.pin_drop,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              NavigatorRoutes.routeStop,
              arguments: stop,
            );
          },
        );
      },
    );
  }
}
