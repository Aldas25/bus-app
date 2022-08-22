import 'package:flutter/material.dart';
import 'package:transit/database/database_service.dart';
import 'package:transit/widgets/app_future_loader.dart';
import 'package:transit/widgets/map/transit_map.dart';

class StopsMapTab extends StatelessWidget {
  const StopsMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService.get(context);

    return AppFutureBuilder<TransitMap>(
      future: database.getAllStops(),
      builder: (BuildContext context, stops) {
        return TransitMap(stops);
      },
    );
  }
}
