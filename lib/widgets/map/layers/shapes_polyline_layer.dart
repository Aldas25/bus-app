import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:latlong2/latlong.dart';

class ShapesPolylineLayer {
  final List<List<Shape>> lines;
  final Color color;

  ShapesPolylineLayer({
    required this.lines,
    required this.color,
  });

  PolylineLayerOptions buildLayer() {
    return PolylineLayerOptions(
      polylines: [
        for (final shapes in lines)
          Polyline(
            points: [
              for (final shape in shapes)
                LatLng(shape.shape_pt_lat, shape.shape_pt_lon),
            ],
            color: color,
            strokeWidth: 5,
          ),
      ],
    );
  }
}
