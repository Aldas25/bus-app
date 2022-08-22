import 'package:flutter/material.dart';
import 'package:gtfs_db/gtfs_db.dart';
import 'package:latlong2/latlong.dart';
import 'package:transit/utils.dart';

extension TransitRouteExtensions on TransitRoute {
  Color? get parsedRouteColor {
    if (route_color != null) {
      return hexToColor(route_color!);
    }

    return null;
  }

  Color? get parsedRouteTextColor {
    if (route_text_color != null) {
      return hexToColor(route_text_color!);
    }

    return null;
  }
}

extension StopExtensions on Stop {
  LatLng get latLng {
    return LatLng(stop_lat, stop_lon);
  }
}
